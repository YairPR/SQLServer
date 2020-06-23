-- Query to find latest "Full" as well as "T-Log" backup of all specified Databases 
USE MSDB
GO

SELECT msdb.dbo.backupset.server_name
    ,msdb.dbo.backupset.database_name
    ,CASE msdb.dbo.backupset.[type] -- Let's decode the main types of backup here
        WHEN 'D'
            THEN 'Full'
        WHEN 'I'
            THEN 'Differential'
        WHEN 'L'
            THEN 'Transaction Log'
        WHEN 'F'
            THEN 'File or filegroup'
        WHEN 'G'
            THEN 'Differential file'
        WHEN 'P'
            THEN 'Partial'
        WHEN 'Q'
            THEN 'Differential partial'
        ELSE msdb.dbo.backupset.[type]
        END AS BackupType
    ,msdb.dbo.backupset.backup_start_date
    ,msdb.dbo.backupset.backup_finish_date
    ,CAST((CAST(DATEDIFF(s, msdb.dbo.backupset.backup_start_date, msdb.dbo.backupset.backup_finish_date) AS INT)) / 3600 AS VARCHAR) + ' hours, ' + CAST((CAST(DATEDIFF(s, msdb.dbo.backupset.backup_start_date, msdb.dbo.backupset.backup_finish_date) AS INT)) / 60 AS VARCHAR) + ' minutes, ' + CAST((CAST(DATEDIFF(s, msdb.dbo.backupset.backup_start_date, msdb.dbo.backupset.backup_finish_date) AS INT)) % 60 AS VARCHAR) + ' seconds' AS [Total_Time_Taken_For_Backup]
    ,msdb.dbo.backupmediafamily.physical_device_name AS Backup_File_Location
FROM msdb.dbo.backupmediafamily
INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id
WHERE (
        backup_set_ID IN (
            SELECT MAX(backup_set_id)
            FROM msdb.dbo.backupset
            WHERE msdb.dbo.backupset.[type] = 'D'
            GROUP BY database_name
            )
        OR backup_set_ID IN (
            SELECT MAX(backup_set_id)
            FROM msdb.dbo.backupset
            WHERE msdb.dbo.backupset.[type] = 'L'
            GROUP BY database_name
            )
        )
ORDER BY msdb.dbo.backupset.backup_finish_date desc
    ,BackupType
GO
