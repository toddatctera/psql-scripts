/* 
__Description__
Select each Cloud Drive Folder named 'Documents' or 'My Documents'.
Show the folder owner's name, total size, number of files and modified date.
Number of files is just files, does not count folders.
Include device syncing these folders and last sync time and update time.
__Usage__
~postgres/bin/psql -U postgres -f query-documents-folders-owners-devices.sql
~postgres/bin/psql -U postgres -f query-documents-folders-owners-devices.sql --csv > /tmp/results.csv
*/
SELECT DISTINCT b2.name AS owner_name ,
                svv.cloud_folder_id AS folder_id ,
                bo.name AS folder_name ,
                fs.timestamp AS folder_update_time,
                fs.total_files AS total_files ,
                pg_size_pretty(fs.folder_size) AS folder_size,
                dsu.device_id ,
                b1.name AS device_name ,
                dcs.sync_update_time ,
                d.device_type ,
                d.version
FROM base_objects bo ,
     base_objects b1 ,
     base_objects b2 ,
     device_sync_uuids dsu,
     device_connection_status dcs,
     devices d ,
     sync_version_vector svv,
     folders_statistics fs
WHERE bo.uid = svv.cloud_folder_id
  AND svv.cloud_folder_id = fs.folder_id
  AND b1.uid = dsu.device_id
  AND b1.is_deleted = 'f'
  AND svv.gvsn_device = dsu.device_sync_uuid
  AND d.uid = dsu.device_id
  AND dsu.device_id = dcs.uid
  AND bo.type = 'com.ctera.db.objects.CloudDrive'
  AND bo.name IN ('Documents','My Documents')
  AND bo.owner_id = b2.uid
  AND bo.is_deleted = 'f'
ORDER BY owner_name;
