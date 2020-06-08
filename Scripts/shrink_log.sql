1)
xp_readerrorlog

2)
dbcc sqlperf(logspace)

3) Backup de log
--COMO SACAR BACKUP DE LOG ADECUDAMENTE
Backup Log [TestDB] to Disk='\\ServidorPivot\D$\UNQTESDB01\TestDb.trn' with compression, INIT, FORMAT, STATS=10
go

--COMO NO SACAR BACKUP DE LOG
Backup Log [TestDB] to Disk=N'NUL' with compression, INIT, FORMAT, STATS=10
go

4) --Hacer shrinkfile
sp_helpdb TestDB

Backup Log [TestDB] to Disk=N'NUL' with compression, INIT, FORMAT, STATS=10
go
Dbcc Shrinkfile(TestDB_log, 512, TRUNCATEONLY)
go

5) -- Redo queue size
SELECT arcs.replica_server_name, d.name, d.log_reuse_wait_desc, drs.log_send_queue_size,drs.redo_queue_size,drs.synchronization_state_desc,drs.last_sent_lsn,
drs.last_received_lsn,drs.last_hardened_lsn,drs.last_hardened_time,redo_queue_size/1024 [RedoqueueSizeMB]
FROM master.sys.databases d
INNER JOIN master.sys.dm_hadr_database_replica_states drs
ON d.database_id=drs.database_id
INNER JOIN master.sys.dm_hadr_availability_replica_cluster_states arcs
ON drs.replica_id=arcs.replica_id
ORDER BY name ASC

6) -- RESUME DE SINCRONIA
ALTER DATABASE [BDNAME] SET HADR RESUME;
GO

===================================================================================================================
--https://www.brentozar.com/archive/2016/03/my-favorite-system-column-log_reuse_wait_desc/
--https://blog.sqlauthority.com/2016/04/07/sql-server-huge-transaction-log-snapshot-replication/
--https://sqltimes.wordpress.com/2013/05/28/sql-server-error-cannot-shrink-log-file-because-the-logical-log-file-located-at-the-end-of-the-file-is-in-use/

sp_helppublication 'snap'
exec sp_repldone null, null, 0,0,1

-- ESPACIO
dbcc sqlperf(logspace)

-- backup full database
BACKUP DATABASE [SAP] 
TO DISK = N'D:\sap_060620.bak' WITH NOFORMAT, NOINIT,  
NAME = N'TSQL-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10
GO

-- backup log
Backup Log [SAP] to Disk=N'NUL' with compression, INIT, FORMAT, STATS=10
go
--COMO SACAR BACKUP DE LOG ADECUDAMENTE
Backup Log [TestDB] to Disk='\\ServidorPivot\D$\UNQTESDB01\TestDb.trn' with compression, INIT, FORMAT, STATS=10
go
--

USE SAP
GO
DBCC LOGINFO
GO

	
SELECT name, log_reuse_wait_desc FROM sys.databases;

-- ultima transaccion
DBCC OPENTRAN

-- verificar si esta activa la replicacion
SELECT name, is_published, is_subscribed, is_merge_published, is_distributor
FROM sys.databases
WHERE    is_published = 1 or is_subscribed = 1 or
        is_merge_published = 1 or is_distributor = 1


USE [SAP]
GO
DBCC SHRINKFILE (N'SAP_log' , 1)
GO


SELECT * FROM sys.database_files;


DBCC LOGINFO;

DBCC SHRINKFILE (2, 100);


USE SAP;  
GO  
-- Truncate the log by changing the database recovery model to SIMPLE.  
ALTER DATABASE SAP  
SET RECOVERY SIMPLE;  
GO  
-- Shrink the truncated log file to 1 MB.  
DBCC SHRINKFILE (sap_log, 1);  --File name SELECT * FROM sys.database_files; query to get the file name
GO  
-- Reset the database recovery model.  
ALTER DATABASE SAP  
SET RECOVERY FULL;  
GO




      
