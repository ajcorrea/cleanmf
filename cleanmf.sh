#!/bin/bash
# Alexandre Jeronimo Correa - ajcorrea@gmail.com
# Script com base inicial no original de Diego Canton de Brito
#
# O Script utiliza o SSHPASS, para instalar:
# apt-get install sshpass (Debian/Ubuntu)
# yum install sshpass (Centos/RH)
#
#
# Instrucoes:
# - Grave o script em um servidor linux
#     # wget https://raw.githubusercontent.com/ajcorrea/cleanmf/master/cleanmf.sh
# - Se utilizar porta ssh diferente de 22, altere o parametro 'port' para a porta correta
#
# Sintaxe do script:
# ./script.sh <senha> <usuario> <xxx.xxx.xxx.> <ip-inicial> <ip-final>
#
# ChangeLog
# 16-05-2016 12:30 - cleanmfv2.sh atualizado com firmware 5.6.5 e adicionado parametro porta para conexao
# 17-05-2016 01:30 - utilizado trigger_url no script interno e script para troca de portas. ATIVADO COMPLIANCE TEST 
# 17-05-2016 10:10 - Removida opcao de COMPLIANCE TEST, comportamento estranho no firmware 5.6.5
# 18-05-2016 13:27 - Criado script clearmfv3ct.sh para ativar o Compliance Test. Adicionado range ip. Tks to Zanix e Diego Canton
# 20-05-2016 13:11 - Adicionada opcao ao ssh para nao gravar o Hostfile do ssh, sugestao de Thiago Montenegro.
#
#
# - Para usar o script de troca de portas ou ativar compliance test:
#   alterar ao final DESTE script a url https://raw.githubusercontent.com/ajcorrea/cleanmf/master/cleanmfv3.sh
#   para a url abaixo (script para troca de portas):
#   https://raw.githubusercontent.com/ajcorrea/cleanmf/master/cleanmfv3portas.sh
#   ou para a url (script para ativar CT):
#   https://raw.githubusercontent.com/ajcorrea/cleanmf/master/cleanmfv3ct.sh
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
uip=$5

if [ -z "$1" ]; then
        pass=fucker
fi
if [ -z "$2" ]; then
        user=mother
fi
if [ -z "$3" ]; then
        #Network
        network="10.0.0."
fi
if [ -z "$4" ]; then
        #Initial IP - algumas redes usam 0 como ip
        ip=0
fi
if [ -z "$5" ]; then
        #Ultimo IP - algumas redes usam 255 como ip
        ip=255
fi
#incrementa para loop
uip=$((uip+1))

while [ $ip -lt $uip ]; do
        sshpass -p $pass ssh -p$port -o UserKnownHostsFile=/dev/null -oConnectTimeout=10 -oStrictHostKeyChecking=no $user@$network$ip "trigger_url https://raw.githubusercontent.com/ajcorrea/cleanmf/master/cleanmfv3.sh | sh"&
        ip=$((ip+1))
done