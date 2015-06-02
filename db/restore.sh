psql -h 127.0.0.1 -U postgres < no-wav-20150602.sql
cat studywav-20150602.sql|psql -h 127.0.0.1 -U postgres -d offirad -c "COPY studywav from STDIN"
