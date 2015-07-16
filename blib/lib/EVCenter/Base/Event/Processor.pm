package EVCenter::Base::Event::Processor;

use Moose;
use Try::Tiny;
use common::sense;
use Class::Load 'try_load_class';
use Module::Pluggable::Object;
use namespace::clean -except => 'meta';
use Log::Any qw/$log/;

has 'drivers'  => (is => 'rw', isa => 'HashRef');
has 'data'     => (is => 'rw', isa => 'HashRef',  default => sub { {} });
has 'event'    => (is => 'rw', isa => 'HashRef',  default => sub { {} });
has 'cstash'   => (is => 'rw', isa => 'HashRef',  default => sub { {} });
has 'includes' => (is => 'rw', default => sub { [] });

sub BUILD {
    my $self = shift;

    # Turn includes into ArrayRef if string
    $self->includes([ $self->includes ]) if ! ref $self->includes;

    my $base = 'EVCenter::Base::Event::Processor';
    my $mp = Module::Pluggable::Object->new( search_path => [ $base ]);

    foreach my $class ($mp->plugins) {
        (my $name = $class) =~ s/\Q${base}::\E//;
        my ($loaded, $error) = try_load_class($class);
        if ($loaded) {
            $log->debug("Loaded $class");
            $self->{drivers}{$name} = $class->new(data     => $self->data, 
                                                  event    => $self->event, 
                                                  cstash   => $self->cstash,
                                                  includes => $self->includes);
        } else {
            $log->debug("Failed to load class $class - $error");
        }
    }
}

sub process_event {
    my ($self, $data) = @_;

    %{$self->data}  = %$data;
    %{$self->event} = ();

    my $probe_type = $self->data->{probe_type};
    my $processor  = $self->drivers->{$probe_type} // $self->drivers->{Default};
    my $common     = $self->drivers->{Common};

    $common->before;
    $processor->before;
    $processor->process;
    $processor->after;
    $common->after;

    return $self->event;
}

1;