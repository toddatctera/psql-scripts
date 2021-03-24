-- Usage: save as a file, e.g. query-Documents-Folders.sql, and run command below as root.
-- ~postgres/bin/psql -U postgres -f query-Documents-Folders.sql > $datadir/query-results.txt
SELECT 
	bo.name AS owner_name,subquery.*
FROM (
SELECT
	fs.owner_id,
	bo.name AS folder_name,
	pg_size_pretty(fs.folder_size) AS Folder_size,
	fs.total_files,
	fs.folder_id,
	fs.timestamp AS Modified_Date
FROM 
	folders_statistics AS fs
	INNER JOIN base_objects AS bo
		ON fs.folder_id = bo.uid
		AND bo.type = 'com.ctera.db.objects.CloudDrive'
WHERE 
	bo.name LIKE 'Documents' OR bo.name LIKE 'My Documents'
	--AND bo.type = 'com.ctera.db.objects.CloudDrive'
	AND fs.is_deleted='f'
) as subquery
JOIN base_objects AS bo ON subquery.owner_id = bo.uid
ORDER BY owner_name, folder_name
LIMIT 50
;

