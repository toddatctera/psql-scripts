-- Query to export list of all devices connected to all tenant portals.
-- Save it in $datadir (/usr/local/lib/ctera)
-- Example Usage: ~postgres/bin/psql -U postgres -f $datadir/export-devices.sql --csv --output '/tmp/devices.csv'
SELECT base_objects.name AS owner_name,
       subquery.device_uid,
       subquery.device_name,
       subquery.portal_name,
       subquery.version,
       subquery.device_type,
       subquery.os_name,
       subquery.last_connected_time
FROM
  ( SELECT osnames.uid AS device_uid,
           bo1.NAME AS device_name,
           bo1.owner_id,
           bo2.NAME AS portal_name,
           osnames.version,
           osnames.device_type,
           osnames.os_name,
           CASE
               WHEN dcs.device_connected=TRUE THEN Now()
               ELSE dcs.update_time
           END AS last_connected_time,
           CASE
               WHEN dcs.device_connected!=TRUE THEN
                      (SELECT Clock_timestamp() - dcs.update_time)
           END AS delta_time_last_connected
   FROM
     (SELECT d.uid, VERSION, device_type, (xpath('/obj/att[@id="status"]/obj/att[@id="agent"]/obj/att[@id="details"]/obj/att[@id="osName"]/val/text()', xmlparse(document xml_field)))[1]::text AS os_name
      FROM devices d,
           device_reported_status drs
      WHERE d.uid = drs.uid) AS osnames,
        base_objects bo1,
        base_objects bo2,
        device_connection_status dcs
   WHERE bo1.uid=osnames.uid
     AND bo2.uid=bo1.portal_id
     AND dcs.uid=bo1.uid
   ORDER BY 3,5,8 DESC) AS subquery
JOIN base_objects ON subquery.owner_id = base_objects.uid
  ORDER BY owner_name;
