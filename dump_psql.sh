#!/bin/sh
STATUS_DOCKER=`docker ps -q`
# BOOLEAN PARA SABER EXITE CONTAINERS ATIVOS 
CONTAINERS_ATIVOS=`echo ${#STATUS_DOCKER}`
DIR="./backup/"
DATA=`date +%d-%m-%Y_%H-%M-%S`
NOME_BACKUP_SQL='pgdump_'$DATA'.sql'

if [ $CONTAINERS_ATIVOS != 0 ]; then
   docker compose down 
fi

docker compose up -d
docker compose exec zabbix-docker-postgres-1 postgres pg_dumpall -U zabbixadmin > $DIR$NOME_BACKUP_SQL
docker compose down

if [ -e "$DIR$NOME_BACKUP_SQL" ]; then
   aws s3 cp $DIR$NOME_BACKUP_SQL $BUCKET_AWS
else
   echo "Arquivo não encontrado"
fi
