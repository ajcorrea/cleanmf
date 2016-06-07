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

# Verificar o uso do Compliance Test
# Compliance Teste Country Code = 511
# Brazil Country code = 76
CCATUAL=$(iwpriv wifi0 getCountryID |  sed 's/wifi0     getCountryID://')
if [ $CCATUAL -eq '511' ]; then
        touch /etc/persistent/ct
        /bin/sed -ir '/radio.1.countrycode/ c radio.1.countrycode=511' /tmp/system.cfg
        /bin/sed -ir '/radio.countrycode/ c radio.countrycode=511' /tmp/system.cfg
fi

#Salva modificacoes...
/bin/cfgmtd -w -p /etc/

fullver=`cat /etc/version`
if [ "$fullver" == "XM.v5.6.6" ]; then
        echo "Atualizado... Done"
        exit
fi
if [ "$fullver" == "XW.v5.6.6" ]; then
        echo "Atualizado... Done"
        exit
fi

versao=`cat /etc/version | cut -d'.' -f1`
cd /tmp
rm -rf /tmp/firmware.bin
rm -rf /tmp/X*.bin

if [ "$versao" == "XM" ]; then
        URL='http://dl.ubnt.com/firmwares/XN-fw/v5.6.6/XM.v5.6.6.29183.160526.1225.bin'        
fi
if [ "$versao" == "XW" ]; then
        URL='http://dl.ubnt.com/firmwares/XW-fw/v5.6.6/XW.v5.6.6.29183.160526.1205.bin'
fi
if [ "$versao" == "TI" ]; then
        URL='http://dl.ubnt.com/firmwares/XN-fw/v5.6.6/TI.v5.6.6.29183.160526.1144.bin'
fi

wget -c $URL -O /tmp/firmware.bin

if [ -e "/tmp/firmware.bin" ] ; then
        ubntbox fwupdate.real -m /tmp/firmware.bin
fi


## http://dl.ubnt.com/firmwares/XN-fw/v5.6.6/XM.v5.6.6.29183.160526.1225.bin
## http://dl.ubnt.com/firmwares/XW-fw/v5.6.6/XW.v5.6.6.29183.160526.1205.bin
## http://dl.ubnt.com/firmwares/XN-fw/v5.6.6/TI.v5.6.6.29183.160526.1144.bin