-----------------------------------------------------------------
-----------SE USA PARA "ESPACIO OCUPADO EN DISCOS"------------------

SET NOCOUNT ON 
go 
exec sp_configure 'show advanced options',1 
reconfigure 
go 
exec sp_configure 'Ole Automation Procedures',1 
reconfigure 
go 



-----------------------------------------------------------------------------
---- TABLA CREADA PARA "GET VLF COUNTS FOR ALL DATABASES ON THE INSTANCE"----

CREATE TABLE #VLFInfo (RecoveryUnitId int,FileID  int,
					   FileSize bigint, StartOffset bigint,
					   FSeqNo      bigint, [Status]    bigint,
					   Parity      bigint, CreateLSN   numeric(38));

CREATE TABLE #VLFCountResults(DatabaseName sysname, VLFCount int);
	 
EXEC sp_MSforeachdb N'Use [?]; 

				INSERT INTO #VLFInfo 
				EXEC sp_executesql N''DBCC LOGINFO([?])''; 
	 
				INSERT INTO #VLFCountResults 
				SELECT DB_NAME(), COUNT(*) 
				FROM #VLFInfo; 

				TRUNCATE TABLE #VLFInfo;'

---------------------------------------------------------------------------
---------------------------------------------------------------------------

---------- TABLA UTILIZADA EN "ERRORES DEL PERIODO"-------------------------
CREATE TABLE errores_log(LogDate datetime, ProcessInfo varchar(30), Logtext nvarchar(4000));
INSERT INTO errores_log
	EXEC sp_readerrorlog;

-----------------------------------------------------------------------------------
------------------------------------------------------------------------------------

Declare @html nvarchar(max), @table nvarchar(max),@html2 nvarchar(max), @table2 nvarchar(max),@html3 nvarchar(max),@table3 nvarchar(max),
@html4 nvarchar(max), @table4 nvarchar(max),@html5 nvarchar(max), @table5 nvarchar(max),@html6 nvarchar(max),@table6 nvarchar(max),
@html7 nvarchar(max),@table7 nvarchar(max),@html8 nvarchar(max), @table8 nvarchar(max),@html9 nvarchar(max),@table9 nvarchar(max),
@html10 nvarchar(max), @table10 nvarchar(max),@html11 nvarchar(max), @table11 nvarchar(max),@html12 nvarchar(max),@table12 nvarchar(max),
@html13 nvarchar(max), @table13 nvarchar(max),@html14 nvarchar(max), @table14 nvarchar(max),@html15 nvarchar(max),@table15 nvarchar(max),
@html16 nvarchar(max),@table16 nvarchar(max), @html17 nvarchar(max),@table17 nvarchar(max),@TEMP AS VARCHAR(4000),@MBfree int,@CMD1 varchar(1000) ; 


----------------------------------------------------------------------
---------------UTILIZADO PARA "ESPACIO EN DISCOS"---------------------



SET @MBfree = 0 
SET @CMD1 = '' 


CREATE TABLE #tbl_xp_fixeddrives 
(Drive varchar(2) NOT NULL, 
[FreeSpace] int NOT NULL) 
INSERT INTO #tbl_xp_fixeddrives(Drive, [FreeSpace]) 
EXEC master.dbo.xp_fixeddrives 
SELECT @TEMP =' 
CREATE FUNCTION dbo.GetDriveSize (@driveletter CHAR(1)) 
RETURNS NUMERIC(20) 
BEGIN 
  DECLARE  @rs INTEGER, @fso INTEGER, @getdrive VARCHAR(13), @drv INTEGER, 
@drivesize VARCHAR(20) 
  SET @getdrive = ''GetDrive("'' + @driveletter + ''")'' 
  EXEC @rs = sp_OACreate ''Scripting.FileSystemObject'', @fso OUTPUT 
  IF @rs = 0 
   EXEC @rs = sp_OAMethod @fso, @getdrive, @drv OUTPUT 
  IF @rs = 0 
   EXEC @rs = sp_OAGetProperty @drv,''TotalSize'', @drivesize OUTPUT 
  IF @rs<> 0 
   SET @drivesize = NULL 
  EXEC sp_OADestroy @drv 
  EXEC sp_OADestroy @fso 
  RETURN @drivesize 
END' 
EXEC(@TEMP) 



------------------------------------------------------------------------
------------------------------------------------------------------------




----------------------------------------------------------------------------
------TABLA 1 - INFORMACION DE VERSION SQL Y OS DE LA INSTANCIA ACTUAL
---------------------------------------------------------------------------

set @html =  
	N'<html><head><title>Chequeo preventivo SQL SERVER 2014</title></head>' + CHAR(10) 
	+ N'<body style="font-family: Arial size:8pt">'  
	+ N'<h1>Chequeo Preventivo SQL SERVER V1.0</h1>'  
	+ N'<table border="1" style="font-size:11px">' 
	+ N'<tr><BR><BR><h5>INFORMACION DE VERSION SQL Y OS DE LA INSTANCIA ACTUAL</h5>' 
	+ N'<tr>' 
	+ N'<th bgcolor="skyblue">Server Name</th>'  
	+ N'<th bgcolor="skyblue">SQL Server and OS Version Info</th>'
	+ N'</tr>' + CHAR(10); 

select @table =  
	CONVERT(nvarchar(max), 
		(select 
		td = isnull(cast(@@SERVERNAME as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(@@VERSION as varchar(500)), 'NULL') 
		FOR XML PATH(N'tr'), TYPE)); 

----------------------------------------------------------------------------
------TABLA 2 - ESPACIO OCUPADO EN DISCOS
---------------------------------------------------------------------------
set @html2 =  
	N'</table><BR><BR><h5>ESPACIO OCUPADO EN DISCOS</h5>' 
	+ N'<table border="1" style="font-size:11px">' 
	+ N'<tr>'  
	+ N'<th bgcolor="skyblue">Disco</th>'  
	+ N'<th bgcolor="skyblue">Tamaño (GB)</th>'
	+ N'<th bgcolor="skyblue">Espacio libre (GB)</th>'  
	+ N'<th bgcolor="skyblue">% Libre</th>'
	+ N'</tr>' + CHAR(10); 

select @table2 =  
	CONVERT(nvarchar(max), 
		(select 
		td = isnull(cast(drive as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(CAST(dbo.GetDriveSize(drive)/1024/1024/1024 as decimal(6,2)) as varchar(500)), 'NULL') 
		,'' ,td = isnull(cast(convert(decimal(6,2), FreeSpace/1024.0) as varchar(500)), 'NULL')
		,'' ,td = isnull(cast(CAST((FreeSpace/(((dbo.GetDriveSize(drive))/1024)/1024))*100.0 as decimal (4,2)) as varchar(500)), 'NULL')
		FROM #tbl_xp_fixeddrives 
		FOR XML PATH(N'tr'), TYPE)); 
 
 DROP TABLE #tbl_xp_fixeddrives 
SELECT @TEMP = 'USE ' 
SELECT @TEMP = @TEMP+'master '+'DROP FUNCTION dbo.GetDriveSize' 
EXEC (@TEMP) 
 
----------------------------------------------------------------------------
------TABLA 3 - DRIVE LEVEL LATENCY INFORMATION
---------------------------------------------------------------------------
set @html3 =  
	N'</table><BR><BR><h5>INFORMACION DEL NIVEL DE LATENCIA DE LOS DISCOS</h5>' 
	+ N'<table border="1" style="font-size:11px">' 
	+ N'<tr>'  
	+ N'<th bgcolor="skyblue">Drive</th>'  
	+ N'<th bgcolor="skyblue">Read Latency</th>'
	+ N'<th bgcolor="skyblue">Write Latency</th>'  
	+ N'<th bgcolor="skyblue">Overall Latency</th>'
	+ N'<th bgcolor="skyblue">Avg Bytes/Read</th>'  
	+ N'<th bgcolor="skyblue">Avg Bytes/Write</th>'
	+ N'<th bgcolor="skyblue">Avg Bytes/Transfer</th>'
	+ N'</tr>' + CHAR(10); 

select @table3 =  
	CONVERT(nvarchar(max), 
		(select 
		td = isnull(cast([Drive] as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(CASE 
		WHEN num_of_reads = 0 THEN 0 
		ELSE (io_stall_read_ms/num_of_reads) END  as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(CASE 
		WHEN io_stall_write_ms = 0 THEN 0 
		ELSE (io_stall_write_ms/num_of_writes) 
	END as varchar(100)), 'NULL')
		,'' ,td = isnull(cast(CASE 
		WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 
		ELSE (io_stall/(num_of_reads + num_of_writes)) 
	END as varchar(100)), 'NULL')
		,'' ,td = isnull(cast(CASE 
		WHEN num_of_reads = 0 THEN 0 
		ELSE (num_of_bytes_read/num_of_reads) 
	END as varchar(100)), 'NULL')
		,'' ,td = isnull(cast(CASE 
		WHEN io_stall_write_ms = 0 THEN 0 
		ELSE (num_of_bytes_written/num_of_writes) 
	END as varchar(100)), 'NULL')
		,'' ,td = isnull(cast(CASE 
		WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 
		ELSE ((num_of_bytes_read + num_of_bytes_written)/(num_of_reads + num_of_writes)) 
	END as varchar(100)), 'NULL')
		FROM (SELECT LEFT(UPPER(mf.physical_name), 2) AS Drive, SUM(num_of_reads) AS num_of_reads,
	         SUM(io_stall_read_ms) AS io_stall_read_ms, SUM(num_of_writes) AS num_of_writes,
	         SUM(io_stall_write_ms) AS io_stall_write_ms, SUM(num_of_bytes_read) AS num_of_bytes_read,
	         SUM(num_of_bytes_written) AS num_of_bytes_written, SUM(io_stall) AS io_stall
      FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
      INNER JOIN sys.master_files AS mf WITH (NOLOCK)
      ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id
      GROUP BY LEFT(UPPER(mf.physical_name), 2)) AS tab
ORDER BY 4
		FOR XML PATH(N'tr'), TYPE)); 

----------------------------------------------------------------------------
------TABLA 4 - TAMAÑO DE LAS BD
---------------------------------------------------------------------------
set @html4 =  
	N'</table><BR><BR><h5>TAMAÑO DE LAS BD</h5>' 
	+ N'<table border="1" style="font-size:11px">' 
	+ N'<tr>'  
	+ N'<th bgcolor="skyblue">DbName</th>'  
	+ N'<th bgcolor="skyblue">Direccion fisica</th>'
	+ N'<th bgcolor="skyblue">Logical Name</th>'  
	+ N'<th bgcolor="skyblue">Tipo archivo</th>'
	+ N'<th bgcolor="skyblue">Size MB</th>'
	+ N'</tr>' + CHAR(10); 

select @table4 =  
	CONVERT(nvarchar(max), 
		(select 
		td = isnull(cast(db_name(database_id) as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(physical_name as varchar(500)), 'NULL') 
		,'' ,td = isnull(cast(name as varchar(500)), 'NULL')
		,'' ,td = isnull(cast(CASE type WHEN 0 THEN 'File' ELSE 'Log' END as varchar(500)), 'NULL')
		,'' ,td = isnull(cast((size * 8)/1024 as varchar(500)), 'NULL')
		FROM sys.master_files 
order by 1,size desc
		FOR XML PATH(N'tr'), TYPE)); 
		
-----------------------------------------------------------------------------------------
------TABLA 5 - ERRORES DEL PERIODO
-----------------------------------------------------------------------------------------
set @html5 =  
	N'</table><BR><BR><h5>ERRORES DEL PERIODO</h5>'
	+ N'<table border="1" style="font-size:11px">' 
	+ N'<tr>'  
	+ N'<th bgcolor="skyblue">Fecha</th>'  
	+ N'<th bgcolor="skyblue">Informacion del proceso</th>'
	+ N'<th bgcolor="skyblue">Descripcion</th>'
	+ N'</tr>' + CHAR(10); 

select @table5 =  
	CONVERT(nvarchar(max), 
		(select TOP (30)
		td = isnull(cast(LogDate as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(ProcessInfo as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(Logtext as nvarchar(4000)), 'NULL')
		FROM errores_log 
ORDER BY LogDate DESC
		FOR XML PATH(N'tr'), TYPE)); 

DROP TABLE errores_log;

----------------------------------------------------------------------------
------TABLA 6 - INFORMACION ACERCA DE TCP LISTENER
---------------------------------------------------------------------------
set @html6 =  
	N'</table><BR><BR><h5>LISTENER TCP</h5>' 
	+ N'<table border="1" style="font-size:11px">' 
	+ N'<tr>'  
	+ N'<th bgcolor="skyblue">Listener_ID</th>'  
	+ N'<th bgcolor="skyblue">IP_Address</th>'
	+ N'<th bgcolor="skyblue">Is IP_v4</th>'
	+ N'<th bgcolor="skyblue">Port</th>'
	+ N'<th bgcolor="skyblue">Type</th>'
	+ N'<th bgcolor="skyblue">State</th>'
	+ N'<th bgcolor="skyblue">Start Time</th>'
	+ N'</tr>' + CHAR(10); 

select @table6 =  
	CONVERT(nvarchar(max), 
		(select 
		td = isnull(cast(listener_id as varchar(10)), 'NULL') 
		,'' ,td = isnull(cast(ip_address as varchar(20)), 'NULL')
		,'' ,td = isnull(cast(is_ipv4  as varchar(3)), 'NULL')
		,'' ,td = isnull(cast(port as varchar(10)), 'NULL')
		,'' ,td = isnull(cast(type_desc as varchar(20)), 'NULL')
		,'' ,td = isnull(cast(state_desc as varchar(20)), 'NULL')
		,'' ,td = isnull(cast(start_time as varchar(30)), 'NULL')
		FROM sys.dm_tcp_listener_states WITH (NOLOCK)
ORDER BY listener_id
		FOR XML PATH(N'tr'), TYPE)); 
 
----------------------------------------------------------------------------
------TABLA 8 - RESPALDOS POR MEDIO DE SQL SERVER
---------------------------------------------------------------------------
set @html8 =  
	N'</table><BR><BR><h5>RESPALDOS POR MEDIO DE SQL SERVER</h5>'  
	+ N'<table border="1" style="font-size:11px">' 
	+ N'<tr>'  
	+ N'<th bgcolor="skyblue">Base de datos</th>'  
	+ N'<th bgcolor="skyblue">Dias sin respaldar</th>'
	+ N'<th bgcolor="skyblue">Ultimo backup</th>'
	+ N'</tr>' + CHAR(10); 

select @table8 =  
	CONVERT(nvarchar(max), 
		(select 
		td = isnull(cast(B.name as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(ISNULL(STR(ABS(DATEDIFF(day, GetDate(),MAX(Backup_finish_date)))), '1000') as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(ISNULL(Convert(char(10), MAX(backup_finish_date), 101), 'NEVER') as varchar(500)), 'NULL')
		FROM    master.dbo.sysdatabases B LEFT OUTER JOIN msdb.dbo.backupset A 
ON      A.database_name = B.name AND A.type = 'D' 
GROUP   BY B.Name 
ORDER   BY B.name
		FOR XML PATH(N'tr'), TYPE)); 

 
-----------------------------------------------------------------------------------------
------TABLA 9 - RECOVERY MODEL, LOG REUSE WAIT DESCRIPTION, LOG FILE SIZE, LOG USAGE SIZE
-----------------------------------------------------------------------------------------
set @html9 =  
	N'</table><BR><BR><h5>MODELO DE RECUPERACION, REUSO DEL LOG, TAMANO DEL LOG, TAMANO USADO DEL LOG</h5>'
	+ N'<table border="1" style="font-size:11px">' 
	+ N'<tr>'  
	+ N'<th bgcolor="skyblue">Database Name</th>'  
	+ N'<th bgcolor="skyblue">Recovery Model</th>'
	+ N'<th bgcolor="skyblue">Log Reuse Wait Description</th>'
	+ N'<th bgcolor="skyblue">Log Size (KB)</th>'
	+ N'<th bgcolor="skyblue">Log Used (KB)</th>'
	+ N'<th bgcolor="skyblue">Log Used %</th>'
	+ N'<th bgcolor="skyblue">DB Compatibility Level</th>'
	+ N'<th bgcolor="skyblue">Page Verify Option</th>' 
	+ N'<th bgcolor="skyblue">is_auto_create_stats_on</th>'  
	+ N'<th bgcolor="skyblue">is_auto_update_stats_on</th>'
	+ N'<th bgcolor="skyblue">is_auto_update_stats_async_on</th>'
	+ N'<th bgcolor="skyblue">is_parameterization_forced</th>'
	+ N'<th bgcolor="skyblue">snapshot_isolation_state_desc</th>'
	+ N'<th bgcolor="skyblue">is_read_committed_snapshot_on</th>'
	+ N'<th bgcolor="skyblue">is_auto_close_on</th>'
	+ N'<th bgcolor="skyblue">is_auto_shrink_on</th>'
	+ N'<th bgcolor="skyblue">is_cdc_enabled</th>'
	+ N'</tr>' + CHAR(10); 

select @table9 =  
	CONVERT(nvarchar(max), 
		(select 
		td = isnull(cast(db.[name] as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(db.recovery_model_desc as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(db.log_reuse_wait_desc as varchar(100)), 'NULL')
		,'' ,td = isnull(cast(ls.cntr_value as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(lu.cntr_value as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(CAST(CAST(lu.cntr_value AS FLOAT) / CAST(ls.cntr_value AS FLOAT)AS DECIMAL(18,2)) * 100 as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(db.[compatibility_level] as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(db.page_verify_option_desc as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(db.is_auto_create_stats_on as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(db.is_auto_update_stats_on as varchar(100)), 'NULL')
		,'' ,td = isnull(cast(db.is_auto_update_stats_async_on as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(is_parameterization_forced as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(db.snapshot_isolation_state_desc as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(db.is_read_committed_snapshot_on as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(db.is_auto_close_on as varchar(100)), 'NULL')
		,'' ,td = isnull(cast(db.is_auto_shrink_on as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(db.is_cdc_enabled as varchar(100)), 'NULL')
		FROM sys.databases AS db WITH (NOLOCK)
INNER JOIN sys.dm_os_performance_counters AS lu WITH (NOLOCK)
ON db.name = lu.instance_name
INNER JOIN sys.dm_os_performance_counters AS ls WITH (NOLOCK) 
ON db.name = ls.instance_name
WHERE lu.counter_name LIKE N'Log File(s) Used Size (KB)%' 
AND ls.counter_name LIKE N'Log File(s) Size (KB)%'
AND ls.cntr_value > 0 
		FOR XML PATH(N'tr'), TYPE)); 
----------------------------------------------------------------------------
------TABLA 3 - INFORMACION DEL HARDWARE DEL SQL SERVER
---------------------------------------------------------------------------
/*set @html9 =  
	N'</table><BR><BR><h5>INFORMACION DEL HARDWARE DEL SQL SERVER</h5>' 
	+ N'<table border="1" style="font-size:11px">' 
	+ N'<tr>'  
	+ N'<th bgcolor="skyblue">Logical CPU Count</th>'  
	+ N'<th bgcolor="skyblue">Hyperthread Ratio</th>'
	+ N'<th bgcolor="skyblue">Physical CPU Count</th>'
	+ N'<th bgcolor="skyblue">Physical Memory (MB)</th>'
	+ N'<th bgcolor="skyblue">sqlserver_start_time</th>'
	+ N'</tr>' + CHAR(10); 

select @table9 =  
	CONVERT(nvarchar(max), 
		(select 
		td = isnull(cast([cpu_count] as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast([hyperthread_ratio] as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast([cpu_count]/[hyperthread_ratio] as varchar(100)), 'NULL')
		,'' ,td = isnull(cast([physical_memory_kb]/1024 as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast([sqlserver_start_time] as varchar(100)), 'NULL') 
		FROM sys.dm_os_sys_info WITH (NOLOCK)
		FOR XML PATH(N'tr'), TYPE)); */


-----------------------------------------------------------------------------------------
------TABLA 7 - EJECUCION DE JOBS CON ERRORES
-----------------------------------------------------------------------------------------
set @html7 =  
	N'</table><BR><BR><h5>EJECUCION DE JOBS CON ERRORES</h5>'
	+ N'<table border="1" style="font-size:11px">' 
	+ N'<tr>'  
	+ N'<th bgcolor="skyblue">Nombre de job</th>'  
	+ N'<th bgcolor="skyblue">Estado</th>'
	+ N'<th bgcolor="skyblue">Fecha</th>'
	+ N'</tr>' + CHAR(10); 

select @table7 =  
	isnull(CONVERT(nvarchar(max), 
		(select
		td = isnull(cast(name as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(last_run_outcome as varchar(100)), 'NULL')
		,'' ,td = isnull(cast(last_run_date as varchar(100)), 'NULL')
		FROM     msdb.dbo.sysjobs A, msdb.dbo.sysjobservers B
WHERE    A.job_id = B.job_id
AND     (B.last_run_outcome in (0,3,4))
		FOR XML PATH(N'tr'), TYPE)),' '); 



----------------------------------------------------------------------------
------TABLA 10 - GET VLF COUNTS FOR ALL DATABASES ON THE INSTANCE
---------------------------------------------------------------------------
set @html10 =  
	N'</table><BR><BR><h5>CANTIDAD DE VLF DE TODAS LAS BD</h5>' 
	+ N'<table border="1" style="font-size:11px">' 
	+ N'<tr>'  
	+ N'<th bgcolor="skyblue">DatabaseName</th>'  
	+ N'<th bgcolor="skyblue">VLFCount</th>'
	+ N'</tr>' + CHAR(10); 

select @table10 =  
	CONVERT(nvarchar(max), 
		(select 
		td = isnull(cast(DatabaseName as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(VLFCount as varchar(100)), 'NULL') 
		FROM #VLFCountResults
ORDER BY VLFCount DESC
		FOR XML PATH(N'tr'), TYPE)); 

DROP TABLE #VLFInfo;
DROP TABLE #VLFCountResults;

----------------------------------------------------------------------------
------TABLA 12 - UTILIZACION DE CPU POR BASE DE DATOS
---------------------------------------------------------------------------
/*set @html12 =  
	N'</table><BR><BR><h5>UTILIZACION DE CPU POR BASE DE DATOS</h5>'  
	+ N'<table border="1" style="font-size:11px">' 
	+ N'<tr>'  
	+ N'<th bgcolor="skyblue">CPU Rank</th>'  
	+ N'<th bgcolor="skyblue">Database Name</th>'
	+ N'<th bgcolor="skyblue">CPU Time (ms)</th>'
	+ N'<th bgcolor="skyblue">CPU Percent</th>'
	+ N'</tr>' + CHAR(10); 
	
	
	WITH DB_CPU_Stats
AS
(SELECT DatabaseID, DB_Name(DatabaseID) AS [Database Name], SUM(total_worker_time) AS [CPU_Time_Ms]
 FROM sys.dm_exec_query_stats AS qs
 CROSS APPLY (SELECT CONVERT(int, value) AS [DatabaseID] 
              FROM sys.dm_exec_plan_attributes(qs.plan_handle)
              WHERE attribute = N'dbid') AS F_DB
 GROUP BY DatabaseID)

select @table12 =  
	CONVERT(nvarchar(max), 
		(select 
		td = isnull(cast(ROW_NUMBER() OVER(ORDER BY [CPU_Time_Ms] DESC) as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast([Database Name] as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast([CPU_Time_Ms] as varchar(100)), 'NULL')
		,'' ,td = isnull(cast(CAST([CPU_Time_Ms] * 1.0 / SUM([CPU_Time_Ms]) OVER() * 100.0 AS DECIMAL(5, 2)) as varchar(100)), 'NULL') 
		FROM DB_CPU_Stats
WHERE DatabaseID <> 32767 -- ResourceDB
ORDER BY 1
		FOR XML PATH(N'tr'), TYPE));*/ 



----------------------------------------------------------------------------
------TABLA 11 - UTILIZACION DE I/O POR BASE DE DATOS
---------------------------------------------------------------------------
set @html11 =  
	N'</table><BR><BR><h5>UTILIZACION DE I/O POR BASE DE DATOS</h5>' 
	+ N'<table border="1" style="font-size:11px">' 
	+ N'<tr>'  
	+ N'<th bgcolor="skyblue">I/O Rank</th>'  
	+ N'<th bgcolor="skyblue">Database Name</th>'
	+ N'<th bgcolor="skyblue">Total I/O (MB)</th>'
	+ N'<th bgcolor="skyblue">I/O Percent</th>' 
	+ N'</tr>' + CHAR(10); 
	
	
	WITH Aggregate_IO_Statistics
AS
(SELECT DB_NAME(database_id) AS [Database Name],
CAST(SUM(num_of_bytes_read + num_of_bytes_written)/1048576 AS DECIMAL(12, 2)) AS io_in_mb
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS [DM_IO_STATS]
GROUP BY database_id)

select @table11 =  
	CONVERT(nvarchar(max), 
		(select 
		td = isnull(cast(ROW_NUMBER() OVER(ORDER BY io_in_mb DESC) as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast([Database Name] as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(io_in_mb as varchar(100)), 'NULL')
		,'' ,td = isnull(cast(CAST(io_in_mb/ SUM(io_in_mb) OVER() * 100.0 AS DECIMAL(5,2)) as varchar(100)), 'NULL')  
		FROM Aggregate_IO_Statistics
ORDER BY 1
		FOR XML PATH(N'tr'), TYPE)); 



-----------------------------------------------------------------------------
------TABLA 12 - USO TOTAL DE BUFFER POR BASE DE DATOS DE LA ACTUAL INSTANCIA
-----------------------------------------------------------------------------
set @html12 =  
	N'</table><BR><BR><h5>USO TOTAL DE BUFFER POR BASE DE DATOS DE LA ACTUAL INSTANCIA</h5>' 
	+ N'<table border="1" style="font-size:11px">' 
	+ N'<tr>'  
	+ N'<th bgcolor="skyblue">Buffer Pool Rank</th>'  
	+ N'<th bgcolor="skyblue">Database Name</th>'
	+ N'<th bgcolor="skyblue">Cached Size (MB)</th>'
	+ N'<th bgcolor="skyblue">Buffer Pool Percent</th>' 
	+ N'</tr>' + CHAR(10); 
	
	
WITH AggregateBufferPoolUsage
AS
(SELECT DB_NAME(database_id) AS [Database Name],
CAST(COUNT(*) * 8/1024.0 AS DECIMAL (10,2))  AS [CachedSize]
FROM sys.dm_os_buffer_descriptors WITH (NOLOCK)
WHERE database_id <> 32767 -- ResourceDB
GROUP BY DB_NAME(database_id))

select @table12 =  
	CONVERT(nvarchar(max), 
		(select 
		td = isnull(cast(ROW_NUMBER() OVER(ORDER BY CachedSize DESC) as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast([Database Name] as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(CachedSize as varchar(100)), 'NULL')
		,'' ,td = isnull(cast(CAST(CachedSize / SUM(CachedSize) OVER() * 100.0 AS DECIMAL(5,2)) as varchar(100)), 'NULL')  
		FROM AggregateBufferPoolUsage
ORDER BY 1
		FOR XML PATH(N'tr'), TYPE)); 

-----------------------------------------------------------------------------
------TABLA 13 - SESIONES POR IP
-----------------------------------------------------------------------------
set @html13 =  
	N'</table><BR><BR><h5>SESIONES POR IP</h5>' 
	+ N'<table border="1" style="font-size:11px">' 
	+ N'<tr>'  
	+ N'<th bgcolor="skyblue">Net Client Address</th>'  
	+ N'<th bgcolor="skyblue">Program Name</th>'
	+ N'<th bgcolor="skyblue">Host Name</th>'
	+ N'<th bgcolor="skyblue">Login Name</th>' 
	+ N'<th bgcolor="skyblue">Connection Count</th>' 
	+ N'</tr>' + CHAR(10); 
	
	
WITH AggregateSessions
AS
(SELECT ec.[client_net_address], es.[program_name], es.[host_name], es.[login_name], 
COUNT(ec.session_id) AS [connection count] 
FROM sys.dm_exec_sessions AS es WITH (NOLOCK) 
INNER JOIN sys.dm_exec_connections AS ec WITH (NOLOCK) 
ON es.session_id = ec.session_id 
GROUP BY ec.client_net_address, es.[program_name], es.[host_name], es.login_name  )

select @table13 =  
	CONVERT(nvarchar(max), 
		(select 
		td = isnull(cast([client_net_address] as varchar(30)), 'NULL') 
		,'' ,td = isnull(cast([program_name] as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast([host_name] as varchar(50)), 'NULL')
		,'' ,td = isnull(cast([login_name] as varchar(100)), 'NULL')
		,'' ,td = isnull(cast([connection count] as varchar(10)), 'NULL') 		
		
		FROM AggregateSessions
		ORDER BY 1,2
		FOR XML PATH(N'tr'), TYPE)); 
-----------------------------------------------------------------------------
------TABLA 13 - DETECT BLOCKING
-----------------------------------------------------------------------------
set @html14 =  
	N'</table><BR><BR><h5>BLOQUEOS EN LA INSTANCIA</h5>' 
	+ N'<table border="1" style="font-size:11px">' 
	+ N'<tr>'  
	+ N'<th bgcolor="skyblue">Lock Type</th>'  
	+ N'<th bgcolor="skyblue">Database Name</th>'
	+ N'<th bgcolor="skyblue">Blk Object</th>'
	+ N'<th bgcolor="skyblue">Lock Req</th>' 
	+ N'<th bgcolor="skyblue">Waiter SID</th>' 
	+ N'<th bgcolor="skyblue">Waite Time(sec)</th>' 
	+ N'<th bgcolor="skyblue">Waiter Statement</th>' 
	+ N'<th bgcolor="skyblue">Blocker SID</th>' 
	+ N'<th bgcolor="skyblue">Blocker Statement</th>' 
	+ N'</tr>' + CHAR(10); 

WITH AggregateBlocks
AS
(SELECT t1.resource_type AS [lock type], DB_NAME(resource_database_id) AS [database],
t1.resource_associated_entity_id AS [blk object],t1.request_mode AS [lock req],  --- lock requested
t1.request_session_id AS [waiter sid], t2.wait_duration_ms/1000 AS [wait time],       -- spid of waiter  
(SELECT [text] FROM sys.dm_exec_requests AS r WITH (NOLOCK)                      -- get sql for waiter
CROSS APPLY sys.dm_exec_sql_text(r.[sql_handle]) 
WHERE r.session_id = t1.request_session_id) AS [waiter_batch],
(SELECT SUBSTRING(qt.[text],r.statement_start_offset/2, 
    (CASE WHEN r.statement_end_offset = -1 
    THEN LEN(CONVERT(nvarchar(max), qt.[text])) * 2 
    ELSE r.statement_end_offset END - r.statement_start_offset)/2) 
FROM sys.dm_exec_requests AS r WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(r.[sql_handle]) AS qt
WHERE r.session_id = t1.request_session_id) AS [waiter_stmt],					-- statement blocked
t2.blocking_session_id AS [blocker sid],										-- spid of blocker
(SELECT [text] FROM sys.sysprocesses AS p										-- get sql for blocker
CROSS APPLY sys.dm_exec_sql_text(p.[sql_handle]) 
WHERE p.spid = t2.blocking_session_id) AS [blocker_stmt]
FROM sys.dm_tran_locks AS t1 WITH (NOLOCK)
INNER JOIN sys.dm_os_waiting_tasks AS t2 WITH (NOLOCK)
ON t1.lock_owner_address = t2.resource_address)

select @table14 =  
	isnull(CONVERT(nvarchar(max), 
		(select 
		td = isnull(cast([lock type] as varchar(20)), ' ') 
		,'' ,td = isnull(cast([database] as varchar(100)), ' ') 
		,'' ,td = isnull(cast([blk object] as varchar(50)), ' ')
		,'' ,td = isnull(cast([lock req] as varchar(20)), ' ')  
		,'' ,td = isnull(cast([waiter sid] as varchar(20)), ' ') 
		,'' ,td = isnull(cast([wait time] as varchar(20)), ' ') 
		,'' ,td = isnull(cast([waiter_batch] as varchar(2000)), ' ')
		,'' ,td = isnull(cast([blocker sid] as varchar(20)), ' ')
		,'' ,td = isnull(cast([blocker_stmt] as varchar(2000)), ' ')
		FROM AggregateBlocks
		FOR XML PATH(N'tr'), TYPE)),' '); 


----------------------------------------------------------------------------
------TABLA 14 - VALORES DE CONFIGURACION DE LA INSTANCIA
---------------------------------------------------------------------------
set @html15 =  
	N'</table><BR><BR><h5>VALORES DE CONFIGURACION DE LA INSTANCIA</h5>' 
	+ N'<table border="1" style="font-size:11px">' 
	+ N'<tr>'  
	+ N'<th bgcolor="skyblue">Name</th>'  
	+ N'<th bgcolor="skyblue">Value</th>'
	+ N'<th bgcolor="skyblue">value_in_use</th>'
	+ N'<th bgcolor="skyblue">minimum</th>'
	+ N'<th bgcolor="skyblue">maximum</th>'
	+ N'<th bgcolor="skyblue">description</th>'
	+ N'<th bgcolor="skyblue">is_dynamic</th>'
	+ N'<th bgcolor="skyblue">is_advanced</th>'
	+ N'</tr>' + CHAR(10); 

select @table15 =  
	CONVERT(nvarchar(max), 
		(select 
		td = isnull(cast([name] as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast([value] as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast([value_in_use] as varchar(100)), 'NULL')
		,'' ,td = isnull(cast([minimum] as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast([maximum] as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast([description] as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast([is_dynamic] as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast([is_advanced] as varchar(100)), 'NULL') 
		from sys.configurations WITH (NOLOCK)
ORDER BY name
		FOR XML PATH(N'tr'), TYPE)); 


---------------------------------------------------------------------------------------------------------------
------TABLA 16 - CALCULES AVERAGE STALLS PER READ, PER WRITE AND PER TOTAL INPUT/OUTPUT FOR EACH DATABASE FILE
---------------------------------------------------------------------------------------------------------------
/*set @html16 =  
	N'</table><BR><BR><h5>CALCULES AVERAGE STALLS PER READ, PER WRITE AND PER TOTAL INPUT/OUTPUT FOR EACH DATABASE FILE</h5>'
	+ N'<table border="1" style="font-size:11px">' 
	+ N'<tr>'  
	+ N'<th bgcolor="skyblue">Database Name</th>'  
	+ N'<th bgcolor="skyblue">avg_read_stall_ms</th>'
	+ N'<th bgcolor="skyblue">avg_write_stall_ms</th>'
	+ N'<th bgcolor="skyblue">avg_io_stall_ms</th>'
	+ N'<th bgcolor="skyblue">File Size (MB)</th>'
	+ N'<th bgcolor="skyblue">physical_name</th>'
	+ N'<th bgcolor="skyblue">type_desc</th>'
	+ N'<th bgcolor="skyblue">io_stall_read_ms</th>' 
	+ N'<th bgcolor="skyblue">num_of_reads</th>'
	+ N'<th bgcolor="skyblue">io_stall_write_ms</th>'
	+ N'<th bgcolor="skyblue">num_of_writes</th>'
	+ N'<th bgcolor="skyblue">io_stalls</th>'
	+ N'<th bgcolor="skyblue">total_io</th>'
	+ N'</tr>' + CHAR(10); 

select @table16 =  
	CONVERT(nvarchar(max), 
		(select 
		td = isnull(cast(DB_NAME(fs.database_id) as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(CAST(fs.io_stall_read_ms/(1.0 + fs.num_of_reads) AS NUMERIC(10,1)) as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(CAST(fs.io_stall_write_ms/(1.0 + fs.num_of_writes) AS NUMERIC(10,1)) as varchar(100)), 'NULL')
		,'' ,td = isnull(cast(CAST((fs.io_stall_read_ms + fs.io_stall_write_ms)/(1.0 + fs.num_of_reads + fs.num_of_writes) AS NUMERIC(10,1)) as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(CONVERT(DECIMAL(18,2), mf.size/128.0) as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(mf.physical_name as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(mf.type_desc as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(fs.io_stall_read_ms as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(fs.num_of_reads as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(fs.io_stall_write_ms as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(fs.num_of_writes as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(fs.io_stall_read_ms + fs.io_stall_write_ms as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(fs.num_of_reads + fs.num_of_writes as varchar(100)), 'NULL')
		FROM sys.dm_io_virtual_file_stats(null,null) AS fs
INNER JOIN sys.master_files AS mf WITH (NOLOCK)
ON fs.database_id = mf.database_id
AND fs.[file_id] = mf.[file_id]
ORDER BY 4 DESC
		FOR XML PATH(N'tr'), TYPE)); */


----------------------------------------------------------------------------
------TABLA 17 - TOP CACHED QUERIES BY EXCECUTION COUNT
---------------------------------------------------------------------------
set @html16 =  
	N'</table><BR><BR><h5>TOP CACHED QUERIES POR NUMERO DE EJECUCIONES</h5>'
	+ N'<table border="1" style="font-size:11px">' 
	+ N'<tr>'  
	+ N'<th bgcolor="skyblue">execution_count</th>'  
	+ N'<th bgcolor="skyblue">total_worker_time</th>'
	+ N'<th bgcolor="skyblue">total_logical_reads</th>'
	+ N'<th bgcolor="skyblue">total_elapsed_time</th>'
	+ N'<th bgcolor="skyblue">query_text</th>'
	+ N'</tr>' + CHAR(10); 

select @table16 =  
	CONVERT(nvarchar(max), 
		(select TOP (30)
		td = isnull(cast(qs.execution_count as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(qs.total_worker_time as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(qs.total_logical_reads as varchar(100)), 'NULL')
		,'' ,td = isnull(cast(qs.total_elapsed_time as varchar(100)), 'NULL') 
		,'' ,td = isnull(cast(SUBSTRING(qt.TEXT,qs.statement_start_offset/2 +1,
(CASE WHEN qs.statement_end_offset = -1
			THEN LEN(CONVERT(NVARCHAR(MAX), qt.TEXT)) * 2
	  ELSE qs.statement_end_offset END - qs.statement_start_offset)/2) as varchar(8000)), 'NULL') 
		FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
ORDER BY qs.execution_count DESC
		FOR XML PATH(N'tr'), TYPE)); 


set @html = @html + @table + @html2 + @table2 + @html3 + @table3 + @html4 + @table4 + @html5 + @table5 + @html6 + @table6 + + @html7 + @table7 + @html8 + @table8 + @html9 + @table9 + @html10 + @table10 + @html11 + @table11 + @html12 + @table12 + @html13 + @table13 + 
@html14 + @table14 + @html15 + @table15 + @html16 + @table16 + CHAR(10)+ N'</table></body></html>'; 

select @html;

-- + @html17 + @table17
GO 
exec sp_configure 'Ole Automation Procedures',0 
RECONFIGURE 
go 
exec sp_configure 'show advanced options',0 
RECONFIGURE 
SET NOCOUNT OFF 
GO
