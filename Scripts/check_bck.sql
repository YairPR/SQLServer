select top(20) * from  msdb.dbo.backupset where database_name='GESTION_ACCESOS' order by backup_start_date desc;

backup log GESTION_ACCESOS to disk='nul' with compression;


sp_helpdb 'GESTION_ACCESOS'

backup database GESTION_ACCESOS to disk='\\10.177.206.23\X$\pyf-prd-db-per\FULL\GESTION_ACCESOS.bak' with compression;
