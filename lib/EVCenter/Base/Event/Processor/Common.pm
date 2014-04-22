package EVCenter::Base::Event::Processor::Common;

use Moose;
use Try::Tiny;
use common::sense;
use File::Find qw/find/;
use File::Spec::Functions;
use Scalar::Util qw/blessed/;
use namespace::clean -except => 'meta';
use Log::Any qw/$log/;
use JSON::MaybeXS;

has 'action'   => (is => 'rw', isa => 'HashRef', default => sub { {} });
has 'data'     => (is => 'rw', isa => 'HashRef', required => 1);
has 'event'    => (is => 'rw', isa => 'HashRef', required => 1);
has 'cstash'   => (is => 'rw', isa => 'HashRef', required => 1);
has 'mstash'   => (is => 'rw', isa => 'HashRef', default => sub { {} });
has 'includes' => (is => 'ro', isa => 'ArrayRef');

sub BUILD {
    our $self = shift;

    our $event   = $self->event;
    our $data    = $self->data;
    our $action  = $self->action;
    our $cstash  = $self->cstash;
    our $mstash  = $self->mstash;

    sub call_action {
        my $action = shift;

        push @{$event->{trace}}, $action;
        if (defined $self->action->{$action} && ref $self->action->{$action} eq 'CODE') {
            return $self->action->{$action}->(@_);
        } else {
            return undef;
        }
    }

    sub discard { $event->{discard}  = 1; }
    sub recover { $event->{discard}  = 0; }
    sub trace   { push @{$event->{trace}}, "@_" };

    my ($module) = (blessed $self) =~ /.*::(.*)/;
    $log->debug("===> Loading module: $module");

    my @include_files;

    File::Find::find( 
        sub {
            push @include_files, $File::Find::name if (-f $_ && $_ !~ /.disabled$/);
        }, 
        map { catfile($_, $module) } @{$self->includes} 
    );

    foreach my $file (sort { $a =~ /\/base/i ? -1 : 1 || $a cmp $b } @include_files) {
        $log->debug("===> Loading $file");
        require "$file";
    }

    $log->debug("===> Running onload sequence");
    $self->onload;
}

sub AUTOLOAD {
    my $self = shift;
    return if ! blessed $self;
    our $AUTOLOAD;
    my ($action) = $AUTOLOAD =~ /.*::(.*)/;
    my ($module) = (blessed $self) =~ /.*::(.*)/;
    if (defined $self->action->{$action}) {
        $log->debug("===> $module : Running call from AUTOLOAD - $action");
        $self->action->{$action}->(@_);
    } else {
        $log->debug("===> $module:  Failed to AUTOLOAD $action - not defined");
    }
}

1;