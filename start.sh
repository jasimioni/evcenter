#!/bin/bash

if [ "$EVCENTER_MODE" = "production" ]; then
    echo "Starting EVCenter in production mode..."
    exec starman --listen "0.0.0.0:3000" --workers 5 evcenter.psgi
else
    echo "Starting EVCenter in development mode..."
    exec perl script/evcenter_server.pl -r -d
fi
