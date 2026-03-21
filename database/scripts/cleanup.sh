#!/bin/bash

export PGPASSWORD=evcenter
PSQL='psql -h 127.0.0.1 -U evcenter evcenter'
echo 'SELECT delete_cleared();' | $PSQL
echo 'SELECT delete_expired();' | $PSQL
