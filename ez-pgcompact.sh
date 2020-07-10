#!/bin/bash
## ezpgcompact.sh
## Version 1.1
## Created By: Justin Flynn
## Modified By: Todd Butters
## Requires: PostgreSQL 9.6+ and pgcompact installed in ~postgres/bin/
## Usage: ez-pgcompact.sh <table_name>

export PATH=$PATH:/usr/local/ctera/postgres/bin
SCRIPT=$(basename $0)
TABLE_NAME=$1
TABLE_EXISTS=$(~postgres/bin/psql -t -c "SELECT EXISTS ( SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = '$1' );" -U postgres)

usage(){
  echo "Usage: ./$SCRIPT <table_name>"
  echo "Please specify 1 table to run pgcompact against."
  echo "Run the following command to see a list of tables."
  echo ""
  echo "~postgres/bin/psql -U postgres -t -c \"SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE';\""
  echo ""
}

if [ $# -eq 0 ]
  then
    echo "No arguments supplied."
    usage
    echo "Exiting $SCRIPT"
    exit 1
fi

if [ $TABLE_EXISTS = 'f' ]; then
  echo "ERROR: Table '$1' not found."
  usage
  echo "Exiting $SCRIPT"
  exit 255
fi

echo "Starting $SCRIPT ..."

# configure pgcompact parms
echo "Setting pgcompact parms..."
echo ""
~postgres/bin/psql -X -c "alter system set autovacuum=off;" -U postgres
~postgres/bin/psql -X -c "alter system set vacuum_cost_delay=10;" -U postgres
~postgres/bin/psql -X -c "alter system set vacuum_cost_limit=2000;" -U postgres
~postgres/bin/psql -X -c "alter system set log_autovacuum_min_duration=0;" -U postgres
~postgres/bin/psql -X -c "alter system set autovacuum_vacuum_cost_limit=200;" -U postgres
~postgres/bin/psql -X -c "select pg_reload_conf();" -U postgres

# kill running autovacs
echo "Cancel running autovacuums..."
echo ""
~postgres/bin/psql -X -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'postgres' AND pid <> pg_backend_pid() AND state = 'active' AND query like 'autovacuum:%';" -U postgres

# start pgcompact
echo "Running pgcompact on the $TABLE_NAME table..."
echo ""
#./pgcompact -v info -d postgres -s -t $TABLE_NAME -o 0 -z 10 -E 1 -c 100 -L -r |& tee "$pglogs/pgcompact-${TABLE_NAME}-$(date '+%d-%m-%Y_%H-%M-%S').log" &'
su - postgres -c "~postgres/bin/pgcompact -v info -d postgres -s -t $TABLE_NAME -o 0 -z 10 -E 1 -c 100 -L -r" | tee "$pglogs/pgcompact-${TABLE_NAME}-$(date '+%d-%m-%Y_%H-%M-%S').log" &

# wait for pgcompact to complete
wait

# configure final auto-vac parms
echo ""
echo "pgcompact complete...Setting final auto-vac parms..."
echo ""
~postgres/bin/psql -X -c "ALTER SYSTEM SET autovacuum=on;" -U postgres
~postgres/bin/psql -X -c "ALTER SYSTEM SET autovacuum_vacuum_cost_delay=10;" -U postgres
~postgres/bin/psql -X -c "ALTER SYSTEM SET autovacuum_vacuum_cost_limit=2000;" -U postgres
~postgres/bin/psql -X -c "ALTER SYSTEM SET autovacuum_naptime=30;" -U postgres
~postgres/bin/psql -X -c "ALTER SYSTEM SET log_autovacuum_min_duration=0;" -U postgres
~postgres/bin/psql -X -c "ALTER SYSTEM SET autovacuum_vacuum_scale_factor=0.05;" -U postgres
~postgres/bin/psql -X -c "ALTER SYSTEM SET autovacuum_vacuum_threshold=10000;" -U postgres
~postgres/bin/psql -X -c "ALTER SYSTEM SET autovacuum_max_workers=10;" -U postgres
~postgres/bin/psql -X -c "ALTER SYSTEM SET autovacuum_analyze_scale_factor=0.05;" -U postgres
~postgres/bin/psql -X -c "ALTER SYSTEM SET autovacuum_analyze_threshold=10000;" -U postgres
~postgres/bin/psql -X -c "ALTER TABLE files SET (autovacuum_vacuum_scale_factor = 0, autovacuum_vacuum_threshold = 100000);" -U postgres
~postgres/bin/psql -X -c "ALTER TABLE blocks SET (autovacuum_vacuum_scale_factor = 0, autovacuum_vacuum_threshold = 100000);" -U postgres
~postgres/bin/psql -X -c "ALTER TABLE logs SET (autovacuum_vacuum_scale_factor = 0, autovacuum_vacuum_threshold = 100000);" -U postgres
~postgres/bin/psql -X -c "ALTER TABLE map_files SET (autovacuum_vacuum_scale_factor = 0, autovacuum_vacuum_threshold = 100000);" -U postgres
~postgres/bin/psql -X -c "ALTER TABLE snapshots SET (autovacuum_vacuum_scale_factor = 0, autovacuum_vacuum_threshold = 100000);" -U postgres
~postgres/bin/psql -X -c "SELECT pg_reload_conf();" -U postgres

# fin
echo "pgcompact complete!"
echo "Exiting $SCRIPT"

exit 0
