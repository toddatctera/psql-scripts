#!/bin/bash
# Run from the primary database.
# Copy, paste, and run the command below.
# Or save as a file, make executable or run bash <filename>.
su - postgres -c "/usr/local/ctera/postgres/bin/psql -X << EOF
SELECT roles.IP,
       roles.server_name,
       CASE
           WHEN roles.replication IS NOT NULL THEN 'Replication'
           WHEN (roles.IsTomcat='true'
                 AND roles.catalog='t') THEN 'DB_Application'
           WHEN roles.catalog='t' THEN 'DB'
           WHEN roles.IsTomcat='true' THEN 'Applicaiton'
           WHEN roles.IsPrev='Active' THEN 'Preview'
           ELSE 'ELSE'
       END AS ROLE
FROM
  (SELECT s.default_ipaddr AS IP,
          bo.name AS SERVER_NAME,
          ((xpath('//att[@id=\"isApplicationServer\"]/val/text ()', XMLPARSE(DOCUMENT xml_field)))[1]::text::text) as IsTomcat, ((xpath('//att[@id=\"previewStatus\"]/val/text ()', XMLPARSE(DOCUMENT xml_field)))[1]::text::text) AS IsPrev,
          bo.type,
          s.connected,
          s.replication_of AS replication,
          s.is_catalog_node AS CATALOG
   FROM base_objects bo,
                     servers s
   WHERE bo.uid IN
       (SELECT UID
        FROM servers)
     AND bo.uid=s.uid
   ORDER BY 4) AS roles;
EOF"
