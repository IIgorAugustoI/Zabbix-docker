#!/bin/sh

# SCRIPT PARA UTILIZAR JUNTO COM O DOCKER COMPOSE

STATUS_DOCKER=`docker ps -q`
# VERIFICAR CONTAINERS ATIVOS
CONTAINERS_ATIVOS=`echo ${#STATUS_DOCKER}`
DIR=./backups/
DATA=`date +%d-%m-%Y_%H-%M-%S`
NOME_BACKUP_SQL='pgdump_'$DATA'.sql'
BUCKET_AWS='Your bucket s3'
BACKUP_COMPACTADO_SQL='backup_pgsql_'$DATA'.tar.gz'

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

efetuaBackup (){
   if [ $CONTAINERS_ATIVOS != 0 ]; then
      docker compose down
   fi
   docker compose up -d
   docker compose exec postgres pg_dump --host=localhost --username=/run/secrets/PGSQL_USER --no-password /run/secrets/PGSQL_DB -w > $DIR$NOME_BACKUP_SQL
   enviaArquivo
}

efetuaBackup
