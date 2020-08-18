#!/bin/bash
if [ "$#" -ne 2 ]
then
  echo "Usage: $0 [-b <backup_folder>] [-c <requested_cloud_folder_name>]"
  exit 1
fi

declare backupFolderName=$1
declare cloudFolderName=$2
declare ownerRes
declare backupFolderUID
declare portal_id
backupFolderUID=$(/usr/local/ctera/postgres/bin/psql -U postgres -qtAX -c "SELECT bu.uid FROM backups bu JOIN base_objects b ON bu.uid = b.uid WHERE b.name='${backupFolderName}'")
if [ -z "${backupFolderUID}" ];
then
	echo "Wrong backup folder name supplied.. backup folder doesn't exist"
  exit 1
fi
ownerRes=$(/usr/local/ctera/postgres/bin/psql -U postgres -qtAX -c "select owner_id from base_objects where uid = $backupFolderUID")
portal_id=$(/usr/local/ctera/postgres/bin/psql -U postgres -qtAX -c "select portal_id from base_objects where uid = $backupFolderUID")
echo "working on the following folder: folder name:${backupFolderName}, folder uid:${backupFolderUID}, folder owner:${ownerRes}"
/usr/local/ctera/postgres/bin/psql -U postgres -qtAX -c "begin;
update base_objects set xml_field = xml(REPLACE(xml_field::text,'<obj class=\"Backup\">', '<obj class=\"CloudDrive\">')) where uid = $backupFolderUID;
update base_objects set xml_field = xml(REPLACE(xml_field::text,'<att id=\"devices\">', '<att id=\"description\">')) where uid = $backupFolderUID;
update base_objects set xml_field = xml(REPLACE(xml_field::text,'<att id=\"domain\"></att>', '<att id=\"domain\"><val>$ownerRes</val></att>')) where uid = $backupFolderUID;
update base_objects set xml_field = xml(REPLACE(xml_field::text,'<att id=\"uid\"></att>', '<att id=\"subType\"><val>null</val></att><att id=\"uid\"></att>')) where uid = $backupFolderUID;
update base_objects set xml_field = xml(REPLACE(xml_field::text,'<att id=\"enableSyncWinNtExtendedAttributes\"></att>', '')) where uid = $backupFolderUID;
update base_objects set xml_field = xml(REPLACE(xml_field::text,'<att id=\"enableBackupExtendedAttributes\"><val>true</val></att>', '<att id=\"enableBackupExtendedAttributes\"><val>true</val></att><att id=\"enableSyncWinNtExtendedAttributes\"><val>true</val></att>')) where uid = $backupFolderUID;
update base_objects set xml_field = xml(REPLACE(xml_field::text,'<att id=\"enableBackupExtendedAttributes\"><val>false</val></att>', '<att id=\"enableBackupExtendedAttributes\"><val>false</val></att><att id=\"enableSyncWinNtExtendedAttributes\"></att>')) where uid = $backupFolderUID;
update folders_statistics set base_object_type='com.ctera.db.objects.CloudDrive' where folder_id = $backupFolderUID;
update base_objects set type='com.ctera.db.objects.CloudDrive' where uid = $backupFolderUID;
update base_objects set name='${cloudFolderName}' where uid = $backupFolderUID;
delete from devices_to_folders where folder_id = $backupFolderUID;
delete from backups where uid = $backupFolderUID;
insert into cloud_drives values ($backupFolderUID,null,null);
commit;
Insert into entities_version (uid,type,state,portal_id,version,update_time) values ($backupFolderUID,1,1,$portal_id,nextval('entity_version_sequence'), now());"

exit 0
