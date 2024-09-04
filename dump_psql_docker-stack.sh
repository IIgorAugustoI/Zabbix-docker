#!/bin/bash

# SCRIPT BACKUP TO docker-stack

DIR="./backups/"
DATA=`date +%d-%m-%Y_%H-%M-%S`
# GET CONTAINERS NAME 
CONTAINERS_ATIVOS=`docker ps --format "{{.Names}}"`
CONTAINER_POSTGRES=""
NOME_BACKUP_SQL="pgdump_$DATA.sql"
BUCKET_AWS="BUCKET S3"
BACKUP_COMPACTADO_SQL="backup_pgsql_$DATA.tar.gz"

# FILTER ONLY BY 'postgres'
for str in "${CONTAINERS_ATIVOS[@]}"; do
    if [[ $str =~ "postgres" ]]; then
        CONTAINER_POSTGRES=$str
    fi
done

# SEND FILE TO BUCKET S3
enviaArquivo(){
   cd $DIR
   ARQUIVO_SQL=`find *.sql`
   if [ -e $ARQUIVO_SQL ]; then
       tar -zcvf $BACKUP_COMPACTADO_SQL $ARQUIVO_SQL
       aws s3 cp $BACKUP_COMPACTADO_SQL $BUCKET_AWS
   else
      echo "Arquivo não encontrado"
   fi
   rm -rf $ARQUIVO_SQL
}

# RUN BACKUP
efetuaBackup (){
   docker exec $CONTAINER_POSTGRES pg_dump --host=localhost --username=/run/secrets/PGSQL_USER --no-password /run/secrets/PGSQL_DB -w > $DIR$NOME_BACKUP_SQL
   enviaArquivo
}

efetuaBackup
