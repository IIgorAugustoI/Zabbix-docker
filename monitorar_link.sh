#!/bin/bash

# O script abaixo irá retornar os dias restantes do certificado SSL do domínio desejado.
# Arquivo original: https://github.com/renato308/monitoramento-ssl-zabbix
# Altere o valor da variavel URL para o endereço que irá monitorar

URL=google.com
data=`echo | openssl s_client -servername $URL -connect $URL:${2:-443} 2>/dev/null | openssl x509 -noout -enddate | sed -e 's#notAfter=##'`

ssldate=`date -d "${data}" '+%s'`

nowdate=`date '+%s'`

diff="$((${ssldate}-${nowdate}))"

echo $((${diff}/86400))
