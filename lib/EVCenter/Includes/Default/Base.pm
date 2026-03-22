$action->{before} = sub {
    $event->{node}   = $data->{source};
};

$action->{process} = sub {
    $event->{message} = $data->{message};
    $event->{severity} = $data->{severity};
    $event->{object}   = $data->{object};
    $event->{dedup_id} = $data->{dedup_id};
    $event->{event_id} = $data->{event_id};
    if ($event->{severity} <= 1) {
	    $event->{type} = 2;
    } else {
	    $event->{type} = 1;
    }
};

$action->{after} = sub {
};

1;