select arcs.replica_server_name, d.name,  redo_queue_size/1024 [RedoqueueSizeMB]
FROM master.sys.databases d
INNER JOIN master.sys.dm_hadr_database_replica_states drs
ON d.database_id=drs.database_id
INNER JOIN master.sys.dm_hadr_availability_replica_cluster_states arcs
ON drs.replica_id=arcs.replica_id
ORDER BY name ASC
