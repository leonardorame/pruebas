pg_dump -h 192.168.1.21 -U postgres -d offirad -C --exclude-table-data="studywav" > no-wav-20150602.sql
psql -h 192.168.1.21 -U postgres -d offirad -c "copy (select * from studywav order by idstudy desc limit 10) TO STDOUT"
