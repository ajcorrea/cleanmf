#!/bin/sh
# Alexandre Jeronimo Correa - ajcorrea@gmail.com
# Script para AirOS Ubiquiti
# Remove o worm MF e atualiza para a ultima versao do AirOS disponivel oficial
#
##### NAO ALTERAR ####
/bin/sed -ir '/mcad/ c ' /etc/inittab
/bin/sed -ir '/mcuser/ c ' /etc/passwd
/bin/rm -rf /etc/persistent/https
/bin/rm -rf /etc/persistent/mcuser
/bin/rm -rf /etc/persistent/mf.tar
/bin/rm -rf /etc/persistent/.mf
/bin/rm -rf /etc/persistent/rc.poststart
/bin/rm -rf /etc/persistent/rc.prestart
/bin/kill -HUP `/bin/pidof init`
/bin/kill -9 `/bin/pidof mcad`
/bin/kill -9 `/bin/pidof init`
/bin/kill -9 `/bin/pidof search`
/bin/kill -9 `/bin/pidof mother`
/bin/kill -9 `/bin/pidof sleep`
# ALTERACOES DE PORTAS - Diego Canton
cat /tmp/system.cfg | grep -v http > /tmp/system2.cfg
echo "httpd.https.status=disabled" >> /tmp/system2.cfg
echo "httpd.port=81" >> /tmp/system2.cfg
echo "httpd.session.timeout=900" >> /tmp/system2.cfg
echo "httpd.status=enabled" >> /tmp/system2.cfg
cat /tmp/system2.cfg | uniq > /tmp/system.cfg
rm /tmp/system2.cfg

# Ativa Compliance TEST
touch /etc/persistent/ct

#Salva alteracoes
/bin/cfgmtd -w -p /etc/
/bin/cfgmtd -f /tmp/system.cfg -w

fullver=`cat /etc/version`
if [ "$fullver" == "XM.v5.6.5" ]; then
        echo "Atualizado... Done"
        exit
fi
if [ "$fullver" == "XW.v5.6.5" ]; then
        echo "Atualizado... Done"
        exit
fi

versao=`cat /etc/version | cut -d'.' -f1`
cd /tmp
rm -rf /tmp/X*.bin
if [ "$versao" == "XM" ]; then
        URL='http://dl.ubnt.com/firmwares/XN-fw/v5.6.5/XM.v5.6.5.29033.160515.2119.bin'
        # URL='http://dl.ubnt.com/firmwares/XN-fw/v5.6.4/XM.v5.6.4.28924.160331.1253.bin'
        wget -c $URL
        ubntbox fwupdate.real -m /tmp/XM.v5.6.5.29033.160515.2119.bin
else
        URL='http://dl.ubnt.com/firmwares/XW-fw/v5.6.5/XW.v5.6.5.29033.160515.2108.bin'
        # URL='http://dl.ubnt.com/firmwares/XW-fw/v5.6.4/XW.v5.6.4.28924.160331.1238.bin'
        wget -c $URL
        ubntbox fwupdate.real -m /tmp/XW.v5.6.5.29033.160515.2108.bin
fi