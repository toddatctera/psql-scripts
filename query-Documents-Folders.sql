/* 
__Description__
Select each Cloud Drive Folders named 'Documents' or 'My Documents'.
Show the folder owner's name, total size, number of files and modified date.
Number of files is just files, does not count folders.
__Usage__
Save as a file, e.g. query-Documents-Folders.sql
Then run command below as root.
~postgres/bin/psql -U postgres -f query-Documents-Folders.sql
Or to save as a CSV and open in Excel or some format.
~postgres/bin/psql -U postgres --csv -f query-Documents-Folders.sql > $datadir/query-results.csv
*/
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
	AND fs.is_deleted='f'
) as subquery
JOIN base_objects AS bo ON subquery.owner_id = bo.uid
ORDER BY owner_name, folder_name
LIMIT 50
;

