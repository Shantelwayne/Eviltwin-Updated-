@echo off
set PGPASSWORD=e30bDL6doiy7zFkP
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -h localhost -p 5432 -U hmdm -d postgres -c "DROP DATABASE IF EXISTS hmdm;"
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -h localhost -p 5432 -U hmdm -d postgres -c "CREATE DATABASE hmdm WITH OWNER=hmdm;"
echo Database hmdm reset successfully