#!/bin/bash

export PERL5LIB="${PERL5LIB:-.:lib}"
export EVCENTER_DBHOST="${EVCENTER_DBHOST:-localhost}"
export EVCENTER_DBNAME="${EVCENTER_DBNAME:-evcenter}"
export EVCENTER_DBUSER="${EVCENTER_DBUSER:-evcenter}"
export EVCENTER_DBPASS="${EVCENTER_DBPASS:-evcenter}"
export EVCENTER_DBPORT="${EVCENTER_DBPORT:-5432}"
export EVCENTER_MODE="${EVCENTER_MODE:-development}"

if [ "$EVCENTER_MODE" = "production" ]; then
    echo "Starting EVCenter in production mode..."
    exec starman --listen "0.0.0.0:3000" --workers 5 evcenter.psgi
else
    echo "Starting EVCenter in development mode..."
    exec perl script/evcenter_server.pl -r -d
fi
