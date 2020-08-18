#!/bin/bash
# Usage: sh last_folder_sync.sh <username>

# Create a folder to store all results in and make it writable.
if [ ! -d $datadir/last_folder_sync_dir ]; then
  mkdir $datadir/last_folder_sync_dir 
  chmod 777 $datadir/last_folder_sync_dir
fi

USER=$1

~postgres/bin/psql -c "COPY (
SELECT DISTINCT
        b2.name             AS owner_name        ,
        svv.cloud_folder_id AS folder_id         ,
        bo.name             AS folder_name       ,
        fs.timestamp        AS folder_update_time,
        dsu.device_id                            ,
        b1.name 			AS device_name       ,
        dcs.sync_update_time                     ,
        d.device_type                            ,
        d.version
FROM
        base_objects             bo ,
        base_objects             b1 ,
        base_objects             b2 ,
        device_sync_uuids        dsu,
        device_connection_status dcs,
        devices                  d  ,
        sync_version_vector      svv,
        folders_statistics       fs
WHERE
        bo.uid              = svv.cloud_folder_id
AND     svv.cloud_folder_id = fs.folder_id
AND     b1.uid              = dsu.device_id
AND     b1.is_deleted       = 'f'
AND     svv.gvsn_device     = dsu.device_sync_uuid
AND     d.uid               = dsu.device_id
AND     dsu.device_id       = dcs.uid
AND     bo.type             = 'com.ctera.db.objects.CloudDrive'
AND     bo.owner_id         = b2.uid
AND     bo.is_deleted       = 'f'
AND     LOWER(b2.name) IN ('$USER')
ORDER BY
        device_name)
TO '$datadir/last_folder_sync_dir/$1_last_folder_sync.csv' CSV HEADER;" -U postgres
echo "Report o/p: $datadir/last_folder_sync_dir/$1_last_folder_sync.csv"

exit 0
