<h2> CleanMF v0.5</h2>
---------------------------------------------------------------
Alexandre Jeronimo Correa - ajcorrea@gmail.com<br>
Script com base inicial no original de Diego Canton de Brito
<br>
Agradecimentos:
<br>

        Diego Canton - https://github.com/diegocanton/remove_ubnt_mf
        PVi1 (Git user)
        zanix (Git User) - https://github.com/zanix
        Florian (http://stackoverflow.com/users/1128705/florian-feldhaus)
        Jorge Luiz Taioque - https://github.com/jorgeluiztaioque
<br><br>

O Script utiliza o SSHPASS, para instalar:
- apt-get install sshpass (Debian/Ubuntu)
- yum install sshpass (Centos/RH)


Instrucoes:
-----------------------
- Grave o script em um servidor linux
- wget https://raw.githubusercontent.com/ajcorrea/cleanmf/master/cleanmf_v0.5.sh
- Se utilizar porta ssh diferente de 22, altere o parametro 'port' para a porta correta


Sintaxe do script:<br>
./cleanmf_v0.5.sh -u [usuario] -p [senha] -n 192.168.0.0/24

<br>
ChangeLog
- 16-05-2016 - cleanmfv2.sh atualizado com firmware 5.6.5 e adicionado parametro porta para conexao
- 17-05-2016 - utilizado trigger_url no script interno e script para troca de portas. ATIVADO COMPLIANCE TEST 
- 17-05-2016 - Removida opcao de COMPLIANCE TEST, comportamento estranho no firmware 5.6.5
- 18-05-2016 - Criado script clearmfv3ct.sh para ativar o Compliance Test. Adicionado range ip. Tks to Zanix e Diego Canton
- 20-05-2016 - Adicionada opcao ao ssh para nao gravar o Hostfile do ssh, sugestao de Thiago Montenegro.
- 20-05-2016 - Bug na verificacao de RANGE dos IPS
- 07-06-2016 - Atualizacao para 5.6.6
- 07-06-2016 - Ativacao de Compliance Test efetiva (o script cleanmfv5.sh detecta o uso do CT, caso esteja em uso, mantem o radio em CT)
- 07-06-2016 - Suporte a CIDR - 192.168.0.0/24 ou 192.168.0.0/20
- 07-06-2016 - Uso de getopts informando Usuario, senha e CIDR como parametros -u -p -n
- 08-06-2016 - Log por IP adicionado. Pasta logs
