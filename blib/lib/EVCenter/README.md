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
