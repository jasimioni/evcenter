#!/bin/bash

/usr/bin/pg_dump -s > /home/evcenter/Desenvolvimento/EVCenter/database/schema/schema_history/schema_`date +%Y%m%d`.sql
