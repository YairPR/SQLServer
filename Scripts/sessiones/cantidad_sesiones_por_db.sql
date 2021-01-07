exec sp_who2

SELECT [hostname],COUNT(*)
FROM master.dbo.sysprocesses
WHERE
	([dbid] = db_id('DATABASE_NAME')) AND
	([spid] > 50)
GROUP BY [hostname]
ORDER BY 2 DESC



SELECT DB_NAME(dbid) AS DBName,
COUNT(dbid) AS NumberOfConnections,
loginame
FROM    sys.sysprocesses
GROUP BY dbid, loginame
ORDER BY DB_NAME(dbid)


select a.dbid,b.name, count(a.dbid) as TotalConnections
from sys.sysprocesses a
inner join sys.databases b on a.dbid = b.database_id
group by a.dbid, b.name
 
