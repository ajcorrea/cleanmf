#!/bin/bash
# Script para remocao em massa do virus MF - versao 0.5
#
# Alexandre Jeronimo Correa - ajcorrea@gmail.com
# 07 de Junho de 2016
#
# Agradecimentos:
#         Diego Canton - https://github.com/diegocanton/remove_ubnt_mf
#         PVi1 (Git user)
#         zanix (Git User) - https://github.com/zanix
#         Florian (http://stackoverflow.com/users/1128705/florian-feldhaus)
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
# ./script.sh <senha> <usuario> <CIDR>
#
# o <CIDR> suporta 192.168.0.0/20 ou 192.168.0.0/255.255.240.0 ou ainda 192.168.0.0/29
#
# ChangeLog
# 16-05-2016 12:30 - cleanmfv2.sh atualizado com firmware 5.6.5 e adicionado parametro porta para conexao
# 17-05-2016 01:30 - utilizado trigger_url no script interno e script para troca de portas. ATIVADO COMPLIANCE TEST
# 17-05-2016 10:10 - Removida opcao de COMPLIANCE TEST, comportamento estranho no firmware 5.6.5
# 18-05-2016 13:27 - Criado script clearmfv3ct.sh para ativar o Compliance Test. Adicionado range ip. Tks to Zanix e Diego Canton
# 20-05-2016 13:11 - Adicionada opcao ao ssh para nao gravar o Hostfile do ssh, sugestao de Thiago Montenegro.
# 20-05-2016 14:00 - Bug na verificacao de RANGE dos IPS
# 07-06-2016 13:19 - Atualizacao para 5.6.6
#                    Ativacao de Compliance Test efetiva (o script cleanmfv5.sh detecta o uso do CT, caso esteja em uso, mantem o radio em CT)
#                    Suporte a CIDR - 192.168.0.0/24 ou 192.168.0.0/20
#                    Uso de getopts informando Usuario, senha e CIDR como parametros -u -p -n
# 08-06-2016 02:34 - Script direciona o STDOUT para arquivos por IP (log por IP).
#
#
# Configuracoes/Parametros
#
# Porta para acesso ao SSH do radio.
port=22

#Ativar debug do comando, executar script sem acessar o radio, mostrando o comando que sera executado
#debug="echo "
debug=""

#Script a ser executado dentro do radio
cleanmfscript='https://raw.githubusercontent.com/ajcorrea/cleanmf/master/cleanmfv5.sh'

########### NAO ALTERAR ##################

ajuda() {
        echo "############################################################"
        echo "## CleanMF v0.5 - Remocao em massa do virus Ubiquiti - MF ##"
        echo "## Autor: Alexandre J. Correa - ajcorrea@gmail.com        ##"
        echo "## URL: http://github.com/ajcorrea/cleanmf                ##"
        echo "############################################################"
        echo "## Sintaxe de uso:                                        ##"
        echo "## ./script.sh -u <usuario> -p <senha> -n <cidr>          ##"
        echo "##                                                        ##"
        echo "## o parametro -u suporta os seguintes formatos de CIDR   ##"
        echo "##      -n 192.168.0.0/20                                 ##"
        echo "##      -n 192.168.0.0/255.255.255.248                    ##"
        echo "##                                                        ##"
        echo "############################################################"
        exit 0
}
ctrl=0
while getopts "u:p:n:h" opcoes; do
        case $opcoes in
                u)   user=$OPTARG;ctrl=$((ctrl+1));;
                p)   pass=$OPTARG;ctrl=$((ctrl+1));;
                n)   network=$OPTARG;ctrl=$((ctrl+1));;
                h)   ajuda;exit 0;;
                \?)  echo "Opcao invalida: -$opcoes"; exit 1;;
                :)   echo "Opcao -$opcoes precisa de um parametro."; exit 1;;
        esac
done
if [ $ctrl != '3' ]; then
        ajuda;
        exit 1;
fi

#Funcao baseada na original de Florian (http://stackoverflow.com/users/1128705/florian-feldhaus)
network_address_to_ips() {
  ips=()
  network=(${1//\// })
  iparr=(${network[0]//./ })
  if [[ ${network[1]} =~ '.' ]]; then
    netmaskarr=(${network[1]//./ })
  else
    if [[ $((8-${network[1]})) -gt 0 ]]; then
      netmaskarr=($((256-2**(8-${network[1]}))) 0 0 0)
    elif  [[ $((16-${network[1]})) -gt 0 ]]; then
      netmaskarr=(255 $((256-2**(16-${network[1]}))) 0 0)
    elif  [[ $((24-${network[1]})) -gt 0 ]]; then
      netmaskarr=(255 255 $((256-2**(24-${network[1]}))) 0)
    elif [[ $((32-${network[1]})) -gt 0 ]]; then
      netmaskarr=(255 255 255 $((256-2**(32-${network[1]}))))
    fi
  fi
  [[ ${netmaskarr[2]} == 255 ]] && netmaskarr[1]=255
  [[ ${netmaskarr[1]} == 255 ]] && netmaskarr[0]=255
  # generate list of ip addresses
  for i in $(seq 0 $((255-${netmaskarr[0]}))); do
    for j in $(seq 0 $((255-${netmaskarr[1]}))); do
      for k in $(seq 0 $((255-${netmaskarr[2]}))); do
        for l in $(seq 0 $((255-${netmaskarr[3]}))); do
          ips+=( $(( $i+$(( ${iparr[0]}  & ${netmaskarr[0]})) ))"."$(( $j+$(( ${iparr[1]} & ${netmaskarr[1]})) ))"."$(($k+$(( ${iparr[2]} & ${netmaskarr[2]})) ))"."$(($l+$((${iparr[3]} & ${netmaskarr[3]})) )) )
        done
      done
    done
  done
}

######## Inicio da execucao
network_address_to_ips $network
## IFS=$' '

#Gerando LOGS 
data=`date +%d%m%Y-%H%M%S`
mkdir -p logs/$data > /dev/null 2>&1

for ip in ${ips[@]}; do
        $debug sshpass -p $pass ssh -p$port -o UserKnownHostsFile=/dev/null -oConnectTimeout=10 -oStrictHostKeyChecking=no $user@$ip "trigger_url $cleanmfscript | sh" >logs/$data/$ip.log 2>&1 &
done

echo "Pronto. Logs gravados em logs/$data"
