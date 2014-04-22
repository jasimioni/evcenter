$action->{before} = sub {
    $event->{node}   = $data->{source_address};

    # SNMPv2 to SNMPv1 Compatibility
    if ($data->{version} == 2) {
        my $enterprise = $data->{varbinds}[1]{value};
        if ($enterprise =~ /^\.?(\Q1.3.6.1.6.3.1.1.5\E)\.(\d+)/) {
            $data->{ent_oid}       = $1;
            $data->{generic_trap}  = $2;
            $data->{specific_trap} = 0;
        } elsif ($enterprise =~ /^\.?(.*?)(\.0)?\.(\d+)$/) {
            $data->{ent_oid}       = $1;
            $data->{generic_trap}  = 6;
            $data->{specific_trap} = $3;
        }

    }
};

$action->{process} = sub {
    call_action($data->{ent_oid}) // call_action('ent_oid_not_found');
};

$action->{after} = sub {
};

$action->{ent_oid_not_found} = sub {
    $event->{message} = 'Unknown event received from: ' . $event->{node} .
                        ' | Enterprise: '               . $data->{ent_oid} .
                        ' | Generic Trap: '             . $data->{generic_trap} .
                        ' | Specific Trap: '            . $data->{specific_trap};
    $event->{object} = join('|', $data->{ent_oid}, $data->{generic_trap}, $data->{specific_trap});

    $event->{dedup_id} = $event->{node} . '-' . $event->{object};
    $event->{event_id} = $event->{dedup_id};

    $event->{detail}   = encode_json $data;
};

1;