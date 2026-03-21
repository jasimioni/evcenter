#!/bin/bash

export PERL5LIB=$PERL5LIB:.
export EVCENTER_DBHOST=10.118.0.185
export EVCENTER_DBNAME=evcenter
export EVCENTER_DBUSER=evcenter
export EVCENTER_DBPASS=evcenter
export EVCENTER_DBPORT=5432

perl script/evcenter_server.pl -r -d
