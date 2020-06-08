declare @dbname varchar(256)
IF (OBJECT_ID('tempdb..#space') IS NOT NULL)
            drop table #space

IF (OBJECT_ID('tempdb..#filestats') IS NOT NULL)
            drop table #filestats

IF (OBJECT_ID('tempdb..#filegroup') IS NOT NULL)
            drop table #filegroup

create table #filestats
(fileid int,
filegroup int,
totalextents int,
usedextents int,
name varchar(255),
filename varchar(1000))

create table #filegroup
(groupid int,
groupname varchar(256))

	insert into #filestats
	exec ('DBCC showfilestats with no_infomsgs')

	insert into #filegroup
	select  groupid, groupname
    from sysfilegroups

select g.groupname,
	sum(TotalExtents)*64.0/1024 as TotalSpaceMB,
	sum((TotalExtents - UsedExtents) * 64.0 / 1024.0) AvailSpaceMB
from #filestats f
join #filegroup g on f.filegroup = g.groupid
group by g.groupname

drop table #filestats
drop table #filegroup
set nocount off
