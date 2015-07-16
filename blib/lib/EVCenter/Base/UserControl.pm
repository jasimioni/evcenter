package EVCenter::Base::UserControl;

use Moose;
use Try::Tiny;
use DBIx::Connector;
use Data::Dumper;
use namespace::clean -except => 'meta';
use Log::Any qw/$log/;
use JSON::MaybeXS;
use Hash::Merge::Simple;
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


sub set_user_details {
    my ( $self, $username, $details ) = @_;

    my $error;
    if (my $db_details = $self->get_user_details($username)) {
        try {
            $db_details = encode_json(Hash::Merge::Simple::merge $db_details, $details);
            $self->conn->run(fixup => sub {
                $_->do("UPDATE uc_users SET details = ? WHERE username = ?", {}, $db_details, $username);
            });
        } catch {
            $error = $_;
        };
    } else {
        $error => 'User not found';
    }

    if ($error) {
        $self->errstr($error);
        return undef;
    }

    return 1;
}

sub get_user_details {
    my ( $self, $username ) = @_;

    my $sth = $self->conn->run(fixup => sub {
        my $sth = $_->prepare('SELECT details
                                 FROM uc_users
                                WHERE username = ?');
        $sth->execute($username);
        $sth;
    });     
    if (my ($db_details) = $sth->fetchrow_array) {
        $db_details = '{}' if (! defined $db_details || $db_details eq 'null');
        return decode_json $db_details;
    } else {
        return undef;
    }
}

1;