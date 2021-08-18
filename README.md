# psql-scripts

Collection of bash scripts and prepared statements for PostgreSQL.

## check-tables.sh
Check if a table exists or not. Mostly intended to be used as a function in other scripts to do table name validation.
```
[root@cteraportal]# ./check-tables.sh files
Table files does exist.
[root@cteraportal]# ./check-tables.sh filez
Warning: Table filez does not exist
Run the following command to see a list of valid table names.

~postgres/bin/psql -U postgres -t -c "SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE';"
```

## export-devices.sql
```
[root@cteraportal ctera ]# ~postgres/bin/psql -U postgres -f export-devices.sql
 owner_name  | device_uid |  device_name   | portal_name |   version   |    device_type    |            os_name            |      last_connected_time
-------------+------------+----------------+-------------+-------------+-------------------+-------------------------------+-------------------------------
 syncservice |        594 | vGateway-5439  | portal      | 6.0.589.0   | vGateway          |                               | 2021-06-17 10:30:11.374-04
 SyncService |        752 | svtvgw         | todd        | 7.0.1399.11 | vGateway          |                               | 2021-08-18 11:04:57.513138-04
 SyncService |       1134 | mysmallgateway | todd        | 7.0.1399.11 | vGateway          |                               | 2021-07-23 11:49:40.159-04
 SyncService |        751 | edge-filer     | todd        | 7.0.1399.11 | vGateway          |                               | 2021-07-04 20:08:55.233-04
 SyncService |        595 | genny          | todd        | 7.0.1399.6  | vGateway          |                               | 2021-08-18 11:04:57.513138-04
 SyncService |        730 | filer2         | todd        | 7.0.1399.6  | vGateway          |                               | 2021-08-12 10:45:33.993-04
 SyncService |        732 | filer3         | todd        | 7.0.1399.6  | vGateway          |                               | 2021-08-10 07:51:25.232-04
 todd        |        633 | VTODD-WIN      | todd        | 6.0.901.4   | Workstation Agent | Microsoft Windows 10  (64bit) | 2021-05-03 12:57:57.806-04
 todd-da     |        735 | team-vGateway1 | todd        | 6.0.771.19  | vGateway          |                               | 2021-08-18 11:04:57.513138-04
 user1       |       1624 | mysmallgateway | portal1     | 7.0.1399.11 | vGateway          |                               | 2021-07-23 12:18:53.796-04
(10 rows)
```
