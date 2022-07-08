CREATE USER 'exporter'@'localhost' IDENTIFIED BY 'secret';
GRANT PROCESS, REPLICATION CLIENT ON *.* TO 'exporter'@'localhost';
GRANT SELECT ON performance_schema.* TO 'exporter'@'localhost';
