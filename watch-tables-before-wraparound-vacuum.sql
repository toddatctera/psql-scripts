-- Increase the limit integer to watch more tables
-- Uncomment AND relname IN ('<table1>,<'table2'>) to specify tables to watch.
-- Usage: ~postgres/bin/psql -U postgres -f watch-tables-before-wraparound-vacuum.sql
SELECT
        oid::regclass::text  AS TABLE   ,
        age(relfrozenxid)    AS xid_age ,
        mxid_age(relminmxid) AS mxid_age,
        least(
        (
                SELECT
                        setting::int
                FROM
                        pg_settings
                WHERE
                        name = 'autovacuum_freeze_max_age') - age(relfrozenxid),
        (
                SELECT
                        setting::int
                FROM
                        pg_settings
                WHERE
                        name = 'autovacuum_multixact_freeze_max_age') - mxid_age(relminmxid) ) AS tx_before_wraparound_vacuum,
        pg_size_pretty(pg_total_relation_size(oid))                                            AS size                       ,
        pg_stat_get_last_autovacuum_time(oid)                                                  AS last_autovacuum
FROM
        pg_class
WHERE
        relfrozenxid != 0
        -- AND relname in ('files','blocks')
AND     oid > 16384
ORDER BY
        tx_before_wraparound_vacuum limit 5;

\watch

