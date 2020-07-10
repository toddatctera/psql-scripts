#!/bin/bash
## Check if a table exists in the public schema.
## Usage ./checkTables.sh <table_name>

table_exists=$(~postgres/bin/psql -t -c "SELECT EXISTS ( SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = '$1' );" -U postgres)

if [ $table_exists = 't' ]; then
  echo "Table $1 does exist."
  exit 0
else
  echo 'Warning: Table '$1' does not exist'
  echo "Run the following command to see a list of valid table names."
  echo ""
  echo "~postgres/bin/psql -U postgres -t -c \"SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE';\""
  echo ""
  exit 255
fi

