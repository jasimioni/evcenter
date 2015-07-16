=head1 Variables

The exported variables are $data, $event, $action, $mstash and $cstash.
All of them are Hash References.

=head2 $data

This is the raw data, as received by the EVCenter::Core Webservice

=head2 $event

This is the event that is going to be inserted into the database. 

=head2 $action 

This is the list of known actions. Each module should have one
before, after and process actions. Other actions can be created
and called using call_action('action_name', @params)

=head2 $cstash

This is the common stash. It's shared by all modules. Use it to
save lookups. Remember to populate it from $action->{onload}.

Also, one day the stashes should go to memcache, so they are shared
by processes and even between servers.

=head2 $mstash

This is the module stash.

=head1 $action->{before}

For every event received, the following
actions will be called, in order:

    ${Common::action}->{before};
    ${Module::action}->{before};
    ${Module::action}->{process};
    ${Module::action}->{after};
    ${Common::action}->{after};
 
=cut

$action->{before} = sub {
# Set default values
    $event->{source_type} = $data->{probe_type};
    $event->{source}      = $data->{probe_id} . '@' . $data->{probe_hostname};
    $event->{type}        = 3;    
    $event->{dedup_id}    = '';
    $event->{event_id}    = '';
    $event->{severity}    = 1;

};

=head1 $action->{after}

The code that will be run after the main processing

=cut

$action->{after} = sub {

    # Logs the original event and the trace sequence to the event details
    $event->{detail} = { data => $data, trace => $event->{trace} };
};

1;