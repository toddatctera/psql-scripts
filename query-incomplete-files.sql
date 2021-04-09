/*
Return the file IDs of all files in files table marked as incomplete.
*/
SELECT f.id
FROM files f
LEFT JOIN snapshots s ON f.snapshot_id=s.id
INNER JOIN base_objects bo ON bo.uid=s.cloud_folder_id
WHERE f.completed='f'
  AND s.current='t'
  AND s.is_temp='f'
  AND deleted='f';
  
