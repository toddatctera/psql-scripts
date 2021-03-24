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
