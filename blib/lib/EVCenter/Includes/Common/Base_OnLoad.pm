=head1 $action->{onload}

This will be run once just after the object is created.

Use this to populate Lookup, set defaults items to stash. Remember,
there is no event data yet, so $data and $event will be empty.

There are 2 stashes to be used: $cstash and $mstash. $cstash is a common
stash and is shared between all drivers. $mstash is restricted to the 
module being processed.
=cut

$action->{onload} = sub {
};

1;