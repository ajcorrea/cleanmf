#!/bin/bash
# Alexandre Jeronimo Correa - ajcorrea@gmail.com
# Script com base inicial no original de Diego Canton de Brito
#
# O Script utiliza o SSHPASS, para instalar:
# apt-get install sshpass (Debian/Ubuntu)
# yum install sshpass (Centos/RH)
#
#
# IMPORTANTE: Ao usar o WGET para copiar este script, eh necessario converter o charset utilizando o aplicativo dos2unix
# apt-get install dos2unix (Debian/Ubuntu)
# yum install dos2unix (Centos/RH)
#
# dos2unix <arquivo.sh>
#
#
# Instrucoes:
# - Grave o script em um servidor linux
# - Se utilizar porta ssh diferente de 22, altere o parametro 'port' para a porta correta
#
# Sintaxe do script:
# ./script.sh <senha> <usuario> <xxx.xxx.xxx.>
#
# ChangeLog
# 16-05-2016 12:30 - cleanmfv2.sh atualizado com firmware 5.6.5 e adicionado parametro porta para conexao
#
#
#
# Configuracoes/Parametros
# 
# Porta SSH
port=22

########### NAO ALTERAR ##################
pass=$1
user=$2
network=$3
ip=$4


if [ -z "$1" ]; then
        pass=YOURPASS
fi
if [ -z "$2" ]; then
        user=YOURUSER
fi
if [ -z "$3" ]; then
        #Network
        network="10.0.0."
fi
if [ -z "$4" ]; then
        #Initial IP
        ip=1
fi

while [ $ip -lt 255 ]; do
        sshpass -p $pass ssh -p$port -oConnectTimeout=10 -oStrictHostKeyChecking=no $user@$network$ip "wget -qO- http://189.84.0.254/ubnt/cleanmfv3.sh | sh"&
        ip=`expr $ip + 1`
done