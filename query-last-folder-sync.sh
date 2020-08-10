#!/bin/bash
USER=$1

~postgres/bin/psql -c "COPY (
select distinct
  b2.name as owner_name,
  svv.cloud_folder_id as folder_id,
  bo.name as folder_name,
  fs.timestamp as folder_update_time,
  dsu.device_id,
  b1.name as device_name,
  dcs.sync_update_time,
  d.device_type,
  d.version
from
  base_objects bo,
  base_objects b1,
  base_objects b2,
  device_sync_uuids dsu,
  device_connection_status dcs,
  devices d,
  sync_version_vector svv,
  folders_statistics fs
where
  bo.uid = svv.cloud_folder_id
  and svv.cloud_folder_id = fs.folder_id
  and b1.uid = dsu.device_id
  and b1.is_deleted = 'f'
  and svv.gvsn_device = dsu.device_sync_uuid
  and d.uid = dsu.device_id
  and dsu.device_id = dcs.uid
  and bo.type = 'com.ctera.db.objects.CloudDrive'
  and bo.owner_id = b2.uid
  and bo.is_deleted = 'f'
  and b2.name = '$USER'
order by 
  device_name)
TO '$datadir/$1_last_folder_sync.csv' csv header;" -U postgres
echo "Report o/p: $datadir/$1_last_folder_sync.csv"

exit 0
