/* 
__Description__
Find managed devices where the device name does not match the hostname.
__Usage__
~postgres/bin/psql -U postgres -f query-device-hostname-mismatch.sql
~postgres/bin/psql -U postgres -f query-device-hostname-mismatch.sql --csv > /tmp/results.csv
*/
SELECT subq.*,
       bo.name AS owner_name
FROM
  (SELECT uid,
          owner_id,
          name,
          ((xpath('//att[@id="hostname"]/val/text()', XMLPARSE(DOCUMENT base_objects.xml_field)))[1]::text::text) AS hostname, 
          ((xpath('//att[@id="osId"]/val/text()', XMLPARSE(DOCUMENT base_objects.xml_field)))[1]::text::text) as osID, 
          ((xpath('//att[@id="guid"]/val/text()', XMLPARSE(DOCUMENT base_objects.xml_field)))[1]::text::text) AS guid
   FROM base_objects
   WHERE TYPE='com.ctera.db.objects.ManagedDevice') AS subq
JOIN base_objects AS bo ON subq.owner_id = bo.uid
WHERE subq.name != hostname
ORDER BY owner_name;
