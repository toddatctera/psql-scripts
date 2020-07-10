-- Prepared statement to check status of active vacuum processes.
-- Usage: ~postgres/bin/psql -U postgres -f check-vacuum-details.sql
SELECT *
FROM
        (
                SELECT
                        pgspv.pid                           ,
                        relname AS TABLE                    ,
                        phase                               ,
                        heap_blks_total                     ,
                        heap_blks_scanned                   ,
                        heap_blks_vacuumed                  ,
                        index_vacuum_count                  ,
                        max_dead_tuples                     ,
                        num_dead_tuples                     ,
                        last_autovacuum                     ,
                        last_autoanalyze                    ,
                        last_vacuum  AS last_manual_vacuum  ,
                        last_analyze AS last_Manual_analyze ,
                        wait_event                          ,
                        wait_event_type                     ,
                        state                               ,
                        Query_Age                           ,
                        Backend_Age
                FROM
                        pg_stat_progress_vacuum pgspv
                INNER JOIN
                        pg_stat_all_tables pgsat
                ON
                        pgsat.relid=pgspv.relid
                INNER JOIN
                        (
                                SELECT
                                        pid                                ,
                                        wait_event                         ,
                                        wait_event_type                    ,
                                        state                              ,
                                        age(now(),query_start)   AS Query_Age,
                                        age(now(),backend_start) AS Backend_Age
                                FROM
                                        pg_stat_activity
                                WHERE
                                        state != 'idle') AS stat
                ON
                        stat.pid=pgspv.pid) AS alias;
