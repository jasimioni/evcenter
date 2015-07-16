package EVCenter::Base::ACL;

use Moose;
use Try::Tiny;
use DBIx::Connector;
use Data::Dumper;
use namespace::clean -except => 'meta';
use Log::Any qw/$log/;
use JSON::MaybeXS;

has 'conn'     => ( is => 'ro', isa => 'Object', lazy => 1, builder => '_build_conn' );
has 'dbhost'   => ( is => 'rw', isa => 'Str', default => '' );
has 'dbname'   => ( is => 'rw', isa => 'Str', default => 'evcenter' );
has 'dbuser'   => ( is => 'rw', isa => 'Str', default => '' );
has 'dbpass'   => ( is => 'rw', isa => 'Str', default => '' );
has 'dbport'   => ( is => 'rw', isa => 'Str', default => '' );
has 'dbopts'   => ( is => 'rw', isa => 'Str', default => '' );
has 'dbi_opts' => ( is => 'rw', isa => 'HashRef' );
has 'errstr'   => ( is => 'rw', isa => 'Str' );

sub _build_conn {
    my $self = shift;

    my $dsn = "dbi:Pg:dbname=" . $self->dbname;
    $dsn .= ';host=' . $self->dbhost if ($self->dbhost);
    $dsn .= ';port=' . $self->dbport if ($self->dbport);
    $dsn .= ';opts=' . $self->dbopts if ($self->dbopts);

    $self->{dbi_opts}{RaiseError} = 1;
    $self->{dbi_opts}{PrintError} = 0;

    my $conn = DBIx::Connector->new($dsn, $self->dbuser, $self->dbpass, $self->dbi_opts);

    return $conn;
}

=head1 NAME

EVCenter::Base::ACL - Base class to handle EVCenter User ACL (Access Lists)

=head1 SYNOPSIS

    $acl = EVCenteR::Base::ACL->new(dbhost => $dbhost, 
                                    dbname => $dbname,
                                    dbuser => $dbuser,
                                    dbpass => $dbpass,
                                    dbport => $dbport,
                                    dbopts => $dbopts,
                                    dbi_opts => { $dbi_opts },
                                    );

=head1 DESCRIPTION

This class is used to load the ACL and the SQL Filter associated
to a user. ACL and SQL Filter are taken from the database structure.

=head1 DATABASE TABLES

B<uc_users>

    Contains the username, filter and filter type of the user

B<uc_roles>

    Contains the rolename, filter and the permissions, in json format

B<uc_groups>

    Contains the group names and details

B<uc_group_members>

    Contains the members of groups, for users and groups (groups member of groups)

B<uc_group_roles>

    Associate one or more roles to a group

B<uc_user_roles>

    Associate one or more roles to a user

=head1 METHODS

=head2 get_group_roles
    
    $hash_ref = $self->get_group_roles($groupname);

Returns all roles (by name, on a hash reference) associated directly to C<$groupname>

Each role can have a C<filter> and a C<permissions> key

=cut

sub get_group_roles {
    my ( $self, $groupname ) = @_;

    my $sth = $self->conn->run(fixup => sub {
        my $sth = $_->prepare('SELECT gr.rolename, r.filter, r.permissions
                                 FROM uc_group_roles gr
                            LEFT JOIN uc_roles r ON gr.rolename = r.rolename
                                WHERE gr.groupname = ?');
        $sth->execute($groupname);
        $sth;
    }); 

    my $return = {};
    while (my ($rolename, $filter, $permissions) = $sth->fetchrow_array) {
        $return->{$rolename} = { filter => $filter, permissions => $permissions };
    }
    return $return;
}

=head2 get_user_roles

    $hash_ref = $self->get_user_roles($username);

Returns all roles (by name, on a hash reference) associated directly to C<$username>

Each role can have a C<filter> and a C<permissions> key

=cut

sub get_user_roles {
    my ( $self, $username ) = @_;

    my $sth = $self->conn->run(fixup => sub {
        my $sth = $_->prepare('SELECT ur.rolename, r.filter, r.permissions
                                 FROM uc_user_roles ur
                            LEFT JOIN uc_roles r ON ur.rolename = r.rolename
                                WHERE ur.username = ?');
        $sth->execute($username);
        $sth;
    }); 

    my $return = {};
    while (my ($rolename, $filter, $permissions) = $sth->fetchrow_array) {
        $return->{$rolename} = { filter => $filter, permissions => $permissions };
    }
    return $return;
}

=head2 get_group_tree

Create an HASH with the group tree, based on a leaf group. Will get all parent groups
of the group and for each their parents.

Also, will return the roles associated to each group.

=cut

sub get_group_tree {
    my ( $self, $groupname, $processed ) = @_;

    $processed = {} if ! defined $processed;
    $processed->{$groupname} = 1;

    my $groups;
    foreach my $member_groupname ( $self->get_parent_groups($groupname) ) {
        next if defined $processed->{$member_groupname};
        $processed->{$member_groupname} = 1;
        $groups->{$member_groupname}{roles}  = $self->get_group_roles($member_groupname);
        $groups->{$member_groupname}{memberof} = $self->get_group_tree($member_groupname, { %$processed });
    }

    my $filter;
    foreach my $groupname (keys %$groups) {
        foreach my $role (keys %{$groups->{$groupname}{roles}}) {
            if (defined $groups->{$groupname}{roles}{$role}{filter}) {
                push @$filter, $groups->{$groupname}{roles}{$role}{filter};
            }
        }
    }

    return $groups;
}

=head2 get_user_group_tree

    $self->dump_user_group_tree($username);

Returns the group structure of user $username, with it's roles

=cut

sub get_user_group_tree {
    my ( $self, $username ) = @_;

    my @user_groups = $self->get_user_groups($username);

    my $tree;
    foreach my $group (@user_groups) {
        $tree->{$group}{roles}    = $self->get_group_roles($group);
        $tree->{$group}{memberof} = $self->get_group_tree($group);
    }

    my $return = { memberof => $tree };
    $return->{roles} = $self->get_user_roles($username);

    return $return;
}

=head2 get_user_groups
    
    @user_groups = $self->get_user_groups($username);

Get the groups C<$username> belongs to (directly).

=cut

sub get_user_groups {
    my ( $self, $username ) = @_;

    my $sth = $self->conn->run(fixup => sub {
        my $sth = $_->prepare('SELECT groupname FROM uc_group_members 
                                WHERE member_type = ? AND member_id = ?');
        $sth->execute('user', $username);
        $sth;
    });

    return map { $_->[0] } @{$sth->fetchall_arrayref};
}

=head2 get_all_user_groups
    
    @user_groups = $self->get_all_user_groups($username);

Get the groups C<$username> belongs to, including the parent groups
from the groups it belongs to.

=cut

sub get_all_user_groups {
    my ( $self, $username ) = @_;

    my $tree = $self->get_user_group_tree($username); 
    my @to_check;
    push @to_check, $tree;
    my %groups;
    while (my $c = shift @to_check) {
        map { $groups{$_} = 1 } keys %{$c->{memberof}};
        push @to_check, values %{$c->{memberof}};
    }
    return [ keys %groups ];
}

=head2 get_parent_groups

    @parent_groups = $self->get_parent_groups($groupname);

Returns the groups C<$groupname> is a member of.

=cut

sub get_parent_groups {
    my ( $self, $groupname ) = @_;
    my $sth = $self->conn->run(fixup => sub {
        my $sth = $_->prepare('SELECT groupname FROM uc_group_members 
                                WHERE member_type = ? AND member_id = ?');
        $sth->execute('group', $groupname);
        $sth;
    });

    my @groups = map { $_->[0] } @{$sth->fetchall_arrayref};

    return @groups;
}

=head2 get_permissions

    $acl = $self->get_permissions($username);

Will return the complete ACL for a user, based on:

Permissions from roles directly attached to user.
Permissions from roles of groups the user belongs to (directly)
Permissions from roles of groups of groups (group tree)

=cut

sub get_permissions {
    my ($self, $username) = @_;

    my @user_groups = $self->get_user_groups($username);

    my $groups_permissions     = $self->get_permissions_from_groups(\@user_groups);
    my $user_roles_permissions = $self->get_permissions_from_user_roles($username);

    my $aclorder = [ $self->calculate_permissions($user_roles_permissions),
                     $self->calculate_permissions($groups_permissions) ];
    return $aclorder;                     
}

=head2 calculate_permissions

C<calculate_permissions> will get the output from C<$self->get_permissions_from_groups>
or from C<$self->get_permissions_from_user_roles> and generate an array with 
the list of Grants and Revokes, in the sequence
they must be executed. Remembering that Revokes will occur before Grants
and that most specific roles (from nearer groups) will be processed later.

Also, sibling roles will have the grants and revokes grouped and all revokes
will happen, then all grants.

Output in the form:

    ( 
        [ 'grant|revoke' ] => [ { 'object1' => 'permission1' }, { 'object2' => 'permission2' } ],
        [ 'grant|revoke' ] => [ { 'object3' => 'permission3' }, { 'object4' => 'permission4' } ]
    )   

=cut

sub calculate_permissions {
    my ($self, $permissions) = @_;

    my @grants;
    my @revokes;
    my @aclorder;
    foreach my $permission (@$permissions) {
        if (ref $permission eq 'ARRAY') {
            push @aclorder, $self->calculate_permissions($permission);
        } else {
            $permission = decode_json $permission;
            if (defined $permission->{grant} && @{$permission->{grant}}) {
                push @grants, @{$permission->{grant}};
            }
            if (defined $permission->{revoke} && @{$permission->{revoke}}) {
                push @revokes, @{$permission->{revoke}};
            }
        }
    } 
    # push @aclorder, [ revoke => \@revokes ] if (@revokes);
    foreach my $revoke (@revokes) {
        push @aclorder, [ 'revoke', %$revoke ];
    }
    foreach my $grant (@grants) {
        push @aclorder, [ 'grant', %$grant ];
    }
    #push @aclorder, [ grant  => \@grants  ] if (@grants);

    return @aclorder;
}

=head2 get_permissions_from_groups

    $self->get_permissions_from_groups([ group_list ]);

This will navigate the database structure, getting all permissions
(grants and revokes) associated with the group tree, initiating in the
group list given.

The return of this method is suitable for the C<calculate_permissions> 
method which will set all the authorization levels for the current user.

=cut

sub get_permissions_from_groups {
    my ($self, $groups, $processed) = @_;

    $processed = {} if ! defined $processed;
    my @permissions;
    foreach my $group (@$groups) {
        next if (defined $processed->{$group});
        $processed->{$group} = 1;
        my @group_permissions;
        my @parent_groups = $self->get_parent_groups($group);
        if (@parent_groups) {
            my $parent_permissions = $self->get_permissions_from_groups(\@parent_groups, { %$processed });
            push @group_permissions, $parent_permissions if (@$parent_permissions);
        }

        my $roles = $self->get_group_roles($group);
        foreach my $role (keys %$roles) {
            if (defined $roles->{$role}{permissions}) {
                push @group_permissions, $roles->{$role}{permissions};
            }
        }

        push @permissions, [ @group_permissions ] if (@group_permissions);
    }

    return \@permissions;
}

=head2 get_permissions_from_user_roles

    $self->get_permissions_from_user_roles($username);

Returns the permissions from roles associated directly to C<$username>

The return of this method is suitable for the C<calculate_permissions> 
method which will set all the authorization levels for the current user.

=cut

sub get_permissions_from_user_roles {
    my ( $self, $username ) = @_;

    my $roles = $self->get_user_roles($username);
    my @permissions;
    foreach my $role (keys %$roles) {
        if (defined $roles->{$role}{permissions}) {
            push @permissions, $roles->{$role}{permissions};
        }
    }        

    return \@permissions;
}

=head2 get_filter

    $sql_filter = $self->get_filter($username);

Returns the SQL Filter to restrict the queries from C<$username>.

It will consider:

1. The filter attached directly to the user, considering the rules
to replace, expand (OR) or restrict (AND).

2. The filters associated with roles attached directly to the user. 
The filters from all roles are ORed.

3. The filters associated with roles attached to groups the user belongs to.
Filters from sibling groups are ORed and filters from Parent groups are ANDed

=cut

sub get_filter {
    my ($self, $username) = @_;

    my @user_groups = $self->get_user_groups($username);

    my $groups_filter     = $self->get_filter_from_groups(\@user_groups);
    my $user_roles_filter = $self->get_filter_from_user_roles($username);
    my ($user_filter, $user_filter_type) = $self->get_filter_from_user($username);

    my $filter;
    if (defined $groups_filter && defined $user_roles_filter) {
        $filter = [ -or => [ $groups_filter, $user_roles_filter ]];
    } else {
        $filter = defined $groups_filter ? $groups_filter :
                  defined $user_roles_filter ? $user_roles_filter : undef;
    }

    if (defined $user_filter && $user_filter ne '') {
        if ($user_filter_type eq 'replace') {
            $filter = $user_filter;
        } else {
            my $op = $user_filter_type eq 'expand' ? '-or' : '-and';
            $filter = defined $filter ? [ $op => [ $filter, $user_filter ] ] : $user_filter;
        } 
    }

    return $filter;
}

=head2 get_filter_from_groups

    $self->get_filter_from_groups([ group_list ]);

This method will generate an array with the resulting filter from the group
tree associated with 'groups'. Remembering that sibling groups / roles have
their filters ORed and vertical association (parent groups) have their filters
ANDed.

=cut

sub get_filter_from_groups {
    my ($self, $groups, $processed) = @_;

    $processed = {} if ! defined $processed;
    my @filters;
    foreach my $group (@$groups) {
        next if (defined $processed->{$group});
        $processed->{$group} = 1;
        my $roles = $self->get_group_roles($group);
        my @group_filters;
        foreach my $role (keys %$roles) {
            if (defined $roles->{$role}{filter} && $roles->{$role}{filter} ne '') {
                push @group_filters, decode_json $roles->{$role}{filter};
            }
        }
        my $group_filter = @group_filters > 1 ? [ -or => [ @group_filters ] ] : 
                          @group_filters == 1 ? $group_filters[0] : undef;

        my @parent_groups = $self->get_parent_groups($group);
        if (@parent_groups) {
            my $parent_filter = $self->get_filter_from_groups(\@parent_groups, { %$processed });
            if (defined $parent_filter) {
                $group_filter = defined $group_filter ? [ -and => [ $group_filter, $parent_filter ] ] : $parent_filter;
            }
        }
        push @filters, $group_filter if defined $group_filter;
    }

    return @filters > 1 ? [ -or => [ @filters ] ] : 
          @filters == 1 ? $filters[0] : undef;
}

=head2 get_filter_from_user_roles

    $self->get_filter_from_user_roles($username);

Returns the filters associated to roles directly attached to a user, ORed.

=cut

sub get_filter_from_user_roles {
    my ( $self, $username ) = @_;

    my $roles = $self->get_user_roles($username);

    my @user_filters;
    foreach my $role (keys %$roles) {
        if (defined $roles->{$role}{filter} && $roles->{$role}{filter} ne '') {
            push @user_filters, decode_json $roles->{$role}{filter};
        }
    } 

    return  @user_filters > 1 ? [ -or => [ @user_filters ] ] : 
           @user_filters == 1 ? $user_filters[0] : undef;
}

=head2 get_filter_from_user

    $self->get_filter_from_user($username);

Gets the filter directly attached to a user and it's rule (expand, restrict or replace)

=cut

sub get_filter_from_user {
    my ( $self, $username ) = @_;

    my $sth = $self->conn->run(fixup => sub {
        my $sth = $_->prepare('SELECT filter, filter_type FROM uc_users
                                WHERE username = ?');
        $sth->execute($username);
        $sth;
    }); 

    my ($filter, $filter_type) = $sth->fetchrow_array;
    if (defined $filter) {
        $filter = $filter eq '' ? undef : decode_json $filter;
    }

    return ($filter, $filter_type);    
}

=head2 get_ui_filters

    $hash_ref = $self->get_ui_filters($username)

Returns a hash reference with the filters available at the User Interface.

3 Types of filters exists: 

=item Global: Everyone can select

=item Group:  Only members of the group can select

=item User:   Only the owner can select

=cut

sub get_ui_filters {
    my ( $self, $username ) = @_;

    try {
        my $groups = $self->get_all_user_groups($username);  

        my $sth = $self->conn->run(fixup => sub {
            my $sql = 'SELECT filter_id, filter_name, owner_type, owner, created_by, filter 
                         FROM ui_filters
                        WHERE owner_type = ? OR (owner_type = ? AND owner = ?)';
            my @params = ('global', 'user', $username);
            if (@$groups) {
                $sql .= ' OR (owner_type = ? AND owner IN (' . join(', ', map { '?' } @$groups) . '))';
                push @params, ('group', @$groups);
            }
            my $sth = $_->prepare($sql);
            $sth->execute(@params);
            $sth;
        }); 

        my @ui_filters;
        while (my $row = $sth->fetchrow_hashref) {
            push @ui_filters, $row;
        }
        return \@ui_filters;
    } catch {
        $self->errstr('Failed to get info: ' . $_);
        return undef;
    };
}

=head2 get_ui_views

    $hash_ref = $self->get_ui_views($username)

Returns a hash reference with the views available at the User Interface.

3 Types of filters exists: 

=item Global: Everyone can select

=item Group:  Only members of the group can select

=item User:   Only the owner can select

=cut

sub get_ui_views {
    my ( $self, $username ) = @_;

    try {
        my $groups = $self->get_all_user_groups($username);  

        my $sth = $self->conn->run(fixup => sub {
            my $sql = 'SELECT view_id, view_name, owner_type, owner, created_by, view
                         FROM ui_views
                        WHERE owner_type = ? OR (owner_type = ? AND owner = ?)';
            my @params = ('global', 'user', $username);
            if (@$groups) {
                $sql .= ' OR (owner_type = ? AND owner IN (' . join(', ', map { '?' } @$groups) . '))';
                push @params, ('group', @$groups);
            }
            my $sth = $_->prepare($sql);
            $sth->execute(@params);
            $sth;
        }); 

        my @ui_views;
        while (my $row = $sth->fetchrow_hashref) {
            push @ui_views, $row;
        }
        use Data::Dumper;
        $log->debug(Dumper \@ui_views);
        return \@ui_views;
    } catch {
        $self->errstr('Failed to get info: ' . $_);
        return undef;
    };
}

1;