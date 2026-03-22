EVCenter
========

EVCenter is a solution for Event Consolidation and Correlation.

Event consolidation and correlation are required for effective Fault Management. Although many solutions (such as Nagios and Zabbix) provides an 'Event List', they usually provide information related to data they collect themselves and not from events from other sources.

Many devices have a way to asynchronously report misfunction, threshold crossing, configuration changes or any other event. One common format to report is SNMP Traps, for example. There are some tools which can be used to consolidate these events, such as NagTrap, but most act just as a central storing without the features EVCenter wishes to provide.

EVCenter is built on Perl, using:
  - AnyEvent for Event Collectors and the Event Correlator;
  - Catalyst for the Web Interface and Integration.

Database Backend is implemented using Postgres 9.

Features:
---------

  * Event normalization, with customization of normalized fields;
  * Current (Active) and History Events;
  * Distributed Event Colletors with store-and-forward support;
  * Event Colletors built for: SNMP Traps, File Reading and STDIN Reading (others to be built);
  * Deduplication of events, keeping track of changes on the repeated ones;
  * Fault resolution correlation based only on simple event information;
  * Basic event enrichment implemented out of the box;
  * Parent / Child events support (mainly for root cause visualization);
  * Support for Easy Event Resynchronization (on Agents that support this); 
  


## Installing libraries (Ubuntu 24.04)

```
apt update

apt install cpanminus libcatalyst-perl libcatalyst-devel-perl liblog-any-adapter-filehandle-perl \
            libcatalyst-plugin-compress-perl libcatalyst-plugin-unicode-perl libcatalyst-plugin-smarturi-perl \
            libcatalyst-authentication-store-dbix-class-perl libcatalyst-plugin-session-store-file-perl \
            build-essential libcatalyst-plugin-configloader-perl libcatalyst-plugin-static-simple-perl \
            libcatalyst-model-adaptor-perl libcatalyst-view-tt-perl libcatalyst-view-json-perl \
            libdbix-connector-perl libsql-abstract-more-perl libdbd-pg-perl libhash-merge-simple-perl \
            libcatalyst-action-renderview-perl libdigest-sha-perl

sudo cpanm Catalyst::Plugin::Session::State::Stash Log::Any::Adapter::Catalyst Digest::SHA1     

```

## PostgreSQL

```
sudo apt update && sudo apt install -y postgresql
echo "CREATE USER evcenter WITH PASSWORD 'evcenter';" | sudo -u postgres psql
echo "CREATE DATABASE evcenter OWNER evcenter;" | sudo -u postgres psql
curl -q https://raw.githubusercontent.com/jasimioni/evcenter/refs/heads/master/database/schema/create_database.sql | sudo -u postgres psql evcenter
curl https://raw.githubusercontent.com/jasimioni/evcenter/refs/heads/master/database/schema/PopulateUserControl | sudo -u postgres psql evcenter
```