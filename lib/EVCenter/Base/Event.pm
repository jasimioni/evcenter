package EVCenter::Base::Event;

use Moose;
use Try::Tiny;
use DBIx::Connector;
use SQL::Abstract::More;
use Data::Dumper;
use namespace::clean -except => 'meta';
use JSON::MaybeXS;
use Log::Any qw/$log/;

has 'conn'     => ( is => 'ro', isa => 'Object', lazy => 1, builder => '_build_conn' );
has 'dbhost'   => ( is => 'rw', isa => 'Str', default => '' );
has 'dbname'   => ( is => 'rw', isa => 'Str', default => 'evcenter' );
has 'dbuser'   => ( is => 'rw', isa => 'Str', default => '' );
has 'dbpass'   => ( is => 'rw', isa => 'Str', default => '' );
has 'dbport'   => ( is => 'rw', isa => 'Str', default => '' );
has 'dbopts'   => ( is => 'rw', isa => 'Str', default => '' );
has 'dbi_opts' => ( is => 'rw', isa => 'HashRef' );
has 'errstr'   => ( is => 'rw', isa => 'Str' );
has 'dbfields' => ( is => 'rw', isa => 'HashRef' );
has 'sqla'     => ( is => 'ro', isa => 'Object', default => sub { SQL::Abstract::More->new() } );
has 'fields'   => ( is => 'ro', isa => 'ArrayRef', builder => '_build_fields' );

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

sub _build_fields {
    my $self = shift;
    my $query = 'SELECT * FROM active_events WHERE 1 = 0';
    my $sth = $self->conn->run(fixup => sub {
            my $sth = $_->prepare($query);
            $sth->execute();
            $sth;
    });
    my $columns = $sth->{NAME};
    $sth->finish;
    return $columns;
}

sub check_db {
    my $self = shift;

    my $query = 'SELECT COUNT(*) FROM active_events';
    try {
        my $sth = $self->conn->run(fixup => sub {
                my $sth = $_->prepare($query);
                $sth->execute();
                $sth;
        });
        $sth->finish;
        $self->_build_fields;
        return 1;
    } catch {
        $self->errstr($_);
        return undef;
    };
}

sub add_events {
    my $self = shift;
    $self->errstr('');

    my $events = shift;

    try {
        my $rows = $self->conn->txn(fixup => sub {
                my $rows = 0;
                foreach my $event (@$events) {
                    my $n_event = {};
                    foreach my $field (@{$self->fields}) {
                        if (defined $event->{$field}) {
                            $n_event->{$field} = ref $event->{$field} ? encode_json $event->{$field} : $event->{$field};
                        }
                    }
                    $log->debug("Inserting new event");
                    $log->debug(Dumper $event);
                    $log->debug(Dumper $n_event);
                    my ($query, @params) = $self->sqla->insert('active_events', $n_event);
                    $log->debug("Query is: $query");
                    $_->do($query, {}, @params);
                    $rows++;
                }
                return $rows;
        });
        return $rows;
    } catch {
        $self->errstr($_);
        return undef;
    };
}

sub get_events {
    my $self = shift;
    $self->errstr('');

    my %p = @_;
    my $filter   = $p{filter}   // {};
    my $restrict = $p{restrict} // {};
    my $order_by = $p{order_by} // [];
    my $limit    = $p{limit};

    my ($query, @params) = $self->sqla->select(-columns  => '*', 
                                               -from     => 'active_events',
                                               -where    => [ -and => [ $filter, $restrict ] ],
                                               -order_by => $order_by,
                                               -limit    => $limit,
                                           );

    print STDERR "SQL: $query => Params: ", join(", ", @params), "\n";
                                           
    try {
        my $sth = $self->conn->run(fixup => sub {
                my $sth = $_->prepare($query);
                $sth->execute(@params);
                $sth;
        });

        my $rows = $sth->fetchall_arrayref({});
        $sth->finish;

        return $rows, $sth->{NAME};
    } catch {
        $self->errstr($_);
        return undef;
    };
}

sub del_events {
    my $self = shift;
    $self->errstr('');

    my %p = @_;
    my $filter   = $p{filter}   // {};
    my $restrict = $p{restrict} // {};

    my ($query, @params) = $self->sqla->delete(-from  => 'active_events',
                                               -where => [ -and => [ $filter, $restrict ] ]);

    try {
        my $rows = $self->conn->run(fixup => sub {
            my $rows = $_->do($query, {}, @params);
            $rows;
        });
        return $rows;
    } catch {
        $self->errstr($_);
        return undef;
    };
}

sub upd_events {
    my $self = shift;
    $self->errstr('');

    my %p = @_;
    my $filter   = $p{filter}   // {};
    my $restrict = $p{restrict} // {};
    my $update   = $p{update}   // {};

    my ($query, @params) = $self->sqla->update(-table => 'active_events',
                                               -where => [ -and => [ $filter, $restrict ] ],
                                               -set   => $update,
                                              );

    print "Updating: $query => Params: ", join(", ", @params), "\n";

    try {
        my $rows = $self->conn->run(fixup => sub {
            my $rows = $_->do($query, {}, @params);
            $rows;
        });
        return $rows;
    } catch {
        $self->errstr($_);
        return undef;
    };
}

__PACKAGE__->meta->make_immutable;

1;

=head1 NAME

EVCenter::Base::Event 

=head1 VERSION

This documentation refers to EVCenter::Base::Event version 0.1

=head1 SYNOPSIS
 
    use EVCenter::Base::Event;

    my $ev = EVCenter::Base::Event->new( 
                                    dbhost => 'IP/Hostname of DB Server',
                                    dbname => 'Database Name',
                                    dbuser => 'Database User',
                                    dbpass => 'Database Password',
                                    dbport => 'Database Port',
                                    dbopts => 'Database Options (see DBD::Pg opts)',
                                    dbi_opts => { }, # DBI specific options, such as AutoCommit
              );

    my $inserted_count = $ev->add_events( \@event_list );
    my $deleted_count  = $ev->del_events( filter => \%filter, restrict => \%restrict_filter );
    my $events_hashref = $ev->get_events( filter => \%filter, restrict => \%restrict_filter );
    my $updated_count  = $ev->upd_events( update => \%data, filter => \%filter, restrict => \%restrict_filter );
    print $ev->errstr if ($ev->errstr);

  
=head1 DESCRIPTION

This module is the base for EVCenter access to the Events database. It connects to the database with the
credentials provided and provides basic methods to insert, delete or return events.

=head1 METHODS

=head3 C<new>

Returns a new object.

=head3 C<add_events>

=head3 C<del_events>

    my $deleted = $ev->del_events( filter => \%filter, restrict => \%restrict_filter );

    Delete the rows that matches filter AND restrict filters. Returns the number of deleted events
    or undef on failure.

=head3 C<get_events>

    my $events_hashref = $ev->get_events( filter => \%filter, restrict => \%restrict_filter );

    Returns the events that matches both filter AND restrict. The events are returned as a hash reference
    with the serial number of the event as the key.

    Returns undef on failure.

=head3 C<upd_events>

    my $updated_count = $ev->upd_events( update => \%data, filter => \%filter, restrict => \%restrict_filter );

    Updates the events that match filter AND restrict, setting up the fields in update key.

    Returns the number of updated rows of undef on failure.

=head3 C<filter> - C<restrict> - C<update> FORMAT

    All these values respect SQL::Abstract notation (http://search.cpan.org/~ribasushi/SQL-Abstract-1.74/lib/SQL/Abstract.pm)

    'restrict' is intended to provide a master filter, when it's needed to restrict the user access to only a group
    of events. 'restrict' will always be ANDed to the current filter.

    Examples:

    update = {
        suppression => 1,
        message     => 'Failure on module #1'
    };

    restrict = {
        node => { like => '%CTA%' }
    };

    filter = {
        serial => [ 1024, 1025 ];
    };

    filter = {
        node   => [ 'SVLXGER1' ],
        object => [ 'ETH1' ]
    }

=head3 C<errstr>

$ev->errstr

Gets the last Error String generated. All methods reset this value when called.

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.
Please report problems to Joao Andre Simioni <jasimioni@gmail.com>
 
=head1 AUTHOR

Joao Andre Simioni <jasimioni@gmail.com>

=head1 LICENSE AND COPYRIGHT
 
Copyright (c) 2013 Joao Andre Simioni (<jasimioni@gmail.com>). All rights reserved.

This module is not free software; you cannot use, redistribute it or do anything
without explicit authorization from the author.
