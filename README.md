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
  
Links:
------

- [Installation Guide](docs/INSTALL.md)
- [Building a Docker Container](docs/DOCKER.md)

Required Cron Jobs:
-------------------

Database cleanup is externally handled. Call the functions:
```
SELECT delete_cleared();
SELECT delete_expired();
```

Example cronjob:
```
* * * * * /database/scripts/event_cleanup.sh
```

Event Handling:
---------------

Events are inserted through the general WebService endpoint using JSON-RPC.
An external client sends method event.parse_and_add, for example:

- [probes/clients/insert-event.pl](probes/clients/insert-event.pl) (event insertion example)

Flow overview:

1. JSON-RPC request arrives at [lib/EVCenter/Controller/WebServices.pm](lib/EVCenter/Controller/WebServices.pm).
2. Method event.parse_and_add is resolved and forwarded to [lib/EVCenter/Controller/Private/event.pm](lib/EVCenter/Controller/Private/event.pm), method parse_and_add.
3. parse_and_add does pre-processing and normalizes input (single hashref or arrayref), then calls the Processor model via $c->model('Processor')->process_event(...).
4. The Processor model [lib/EVCenter/Model/Processor.pm](lib/EVCenter/Model/Processor.pm) is backed by [lib/EVCenter/Base/Event/Processor.pm](lib/EVCenter/Base/Event/Processor.pm).
5. Processor selects the driver by probe_type from the incoming event. If probe_type is not defined (or is unknown), it falls back to Default.
6. Processed events are forwarded to add in [lib/EVCenter/Controller/Private/event.pm](lib/EVCenter/Controller/Private/event.pm), which calls $c->model('Event')->add_events(...).
7. Event model [lib/EVCenter/Model/Event.pm](lib/EVCenter/Model/Event.pm) is an adaptor for [lib/EVCenter/Base/Event.pm](lib/EVCenter/Base/Event.pm), which finally writes into the database.

Processor and include rules:

- Each probe type should have a processor driver under [lib/EVCenter/Base/Event/Processor](lib/EVCenter/Base/Event/Processor) (for example SNMPd or Default).
- Include scripts are loaded from [lib/EVCenter/Includes](lib/EVCenter/Includes), under a folder matching the processor module name.
- For each event, the hook order is:
  Common::before -> Module::before -> Module::process -> Module::after -> Common::after
- Typical hook definitions live in Base.pm files (before, process, after), for example:
  [lib/EVCenter/Includes/Common/Base.pm](lib/EVCenter/Includes/Common/Base.pm)
  [lib/EVCenter/Includes/Default/Base.pm](lib/EVCenter/Includes/Default/Base.pm)
  [lib/EVCenter/Includes/SNMPd/Base.pm](lib/EVCenter/Includes/SNMPd/Base.pm)
- Base_OnLoad.pm is executed once when the processor module is loaded, to initialize/cache reusable data, for example:
  [lib/EVCenter/Includes/Common/Base_OnLoad.pm](lib/EVCenter/Includes/Common/Base_OnLoad.pm)
  [lib/EVCenter/Includes/Default/Base_OnLoad.pm](lib/EVCenter/Includes/Default/Base_OnLoad.pm)
  [lib/EVCenter/Includes/SNMPd/Base_OnLoad.pm](lib/EVCenter/Includes/SNMPd/Base_OnLoad.pm)


Database Explanation:
---------------------

Core event tables:

- [database/schema/create_database.sql](database/schema/create_database.sql) defines active_events as the current active-state table.
- Relevant active_events fields:
  - type: 1 = fault, 2 = resolution, 3 = unknown.
  - dedup_id: key used by deduplication logic.
  - event_id: key used to correlate fault and resolution events.
  - severity: current runtime severity.
  - start_severity: original severity at first insertion.
  - trace_dedup: enables storing dedup trace records.
  - update_fields: space-separated field list to be updated on dedup hits.

Trigger/function behavior for active_events:

1. deduplicate trigger (BEFORE INSERT) calls deduplicate().
2. If dedup_id already exists, deduplicate() updates the existing row instead of inserting a new one.
3. On dedup hit, deduplicate() updates severity, last_occurrence, increments count, and optionally updates fields listed in update_fields.
4. If trace_dedup is true, deduplicate() writes a row to deduplication_trace.
5. If not a dedup hit, deduplicate() sets start_severity = severity for the new row.
6. fault_resolution trigger (AFTER INSERT OR UPDATE, when type = 2 and severity >= 1) calls fault_resolution(), which clears matching fault/resolution rows by setting severity = 0 for the same event_id.
7. update_last_change trigger (BEFORE UPDATE) calls update_last_change(), preserving start_severity and refreshing last_change.

History, trace and log tables:

- deduplication_trace stores optional extra records when deduplication happens and trace_dedup is enabled.
- history_events stores a long-term copy of event lifecycle data:
  - z_save_history trigger (AFTER INSERT on active_events) inserts the initial history row.
  - z_update_history trigger (AFTER UPDATE on active_events) keeps history row values synchronized.
  - save_deletion_time trigger (AFTER DELETE on active_events) stamps delete_time in history_events.
- log stores manual/operational event changes such as acknowledgements and suppressions.

ACL and SQL Restriction Filter (SRF):

- Extended ACL schema tables are defined in [database/schema/create_database.sql](database/schema/create_database.sql):
  uc_group_members, uc_group_roles, uc_groups, uc_user_roles, uc_roles, uc_users.
- The ACL engine in [lib/EVCenter/Base/ACL.pm](lib/EVCenter/Base/ACL.pm) builds both:
  - permissions ACL from role grant/revoke JSON.
  - SRF filter from user/role/group filters.
- During login, [lib/EVCenter/Controller/Auth.pm](lib/EVCenter/Controller/Auth.pm) stores SRF in session as srf.
- Event queries/updates apply SRF through the restrict filter in [lib/EVCenter/Controller/Private/event.pm](lib/EVCenter/Controller/Private/event.pm), blocking access to events outside user scope.
- A grant/revoke permission model is present in schema and ACL parsing, but the full management/enforcement surface is not yet complete.

UI views and filters:

- ui_filters stores reusable SQL-style JSON filters for event list selection.
- ui_views stores event list layout metadata (columns/sorting and related options).
- Both support ownership scopes: user, group, global.
- Example records are in [database/schema/PopulateUserControl](database/schema/PopulateUserControl).
- ACL retrieval for these resources is implemented in [lib/EVCenter/Base/ACL.pm](lib/EVCenter/Base/ACL.pm), but full UI management for creating/editing them is still not ready.
