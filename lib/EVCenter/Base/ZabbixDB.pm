package EVCenter::Base::ZabbixDB;

use Moose;
use Try::Tiny;
use DBIx::Connector;
use Data::Dumper;
use namespace::clean -except => 'meta';
use Log::Any qw/$log/;

has 'conn'     => ( is => 'ro', isa => 'Object', lazy => 1, builder => '_build_conn' );
has 'dbhost'   => ( is => 'rw', isa => 'Str', default => 'localhost' );
has 'dbname'   => ( is => 'rw', isa => 'Str', default => 'zabbix' );
has 'dbuser'   => ( is => 'rw', isa => 'Str', default => 'zabbix' );
has 'dbpass'   => ( is => 'rw', isa => 'Str', default => 'zabbixpasswd' );
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

sub is_logged_in {
    my ($self, $sessionid) = @_;

    my $return = 0;
    my $sth = $self->conn->run(fixup => sub {
        my $sth = $_->prepare('SELECT status FROM sessions WHERE userid != ? AND sessionid = ?');
        $sth->execute(2, $sessionid);
        $sth;
    }); 

    if (my ($status) = $sth->fetchrow_array) {
        $return = 1 if $status == 0;
    }

    return $return;
}

1;