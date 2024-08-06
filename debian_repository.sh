#!/bin/bash
CODENAME='stable'
TYPES='deb deb-src'
URIS='http://deb.debian.org/debian'
URIS_SEC='http://deb.debian.org/debian-security'
SUITES="$CODENAME $CODENAME-updates $CODENAME-backports"
SUITES_SEC="$CODENAME-security"
COMPONENTES='main contrib non-free non-free-firmware'
SIGNED="/usr/share/keyrings/debian-archive-keyring.gpg"
PATH_SOURCE="/etc/apt/sources.list.d/$CODENAME.sources"

if [ ! -e $PATH_SOURCE ]
  echo "-------------------------------------------------"
  echo "[ Repositório - $CODENAME ]: Verificando ..."
sleep 2
  then
    echo "[ Repositório - $CODENAME ]: Configurando ..."
sleep 2
    
mv /etc/apt/sources.list /etc/apt/sources.list.bkp 2>&1

cat > $PATH_SOURCE << EOF
## $CODENAME RESPOSITORY ##
Types: $TYPES
URIs: $URIS
Suites: $SUITES
Components: $COMPONENTES
Signed-By: $SIGNED

Types: $TYPES
URIs: $URIS_SEC
Suites: $SUITES_SEC
Components: $COMPONENTES
Signed-By: $SIGNED
EOF

    echo "[ Repositório - $CODENAME ]: OK!"
    echo "-------------------------------------------------"
    else
        echo "[ Repositório - $CODENAME ]: - OK!"
    echo "-------------------------------------------------"
fi
sleep 2

if [ ! -e ~/repo ]
  echo "[ NOVOS Repositórios ]: Verificando ..."
sleep 2
  then
    echo "[ NOVOS Repositórios ]: Não há"
    echo "-------------------------------------------------"
  else
  sh ~/repo
    echo "[ NOVOS Repositórios ]: OK!"
    echo "-------------------------------------------------"
fi
sleep 2

if grep ^'precedence ::ffff:0:0/96  100'  /etc/gai.conf > /dev/null
  echo "[ Prioridade IPv4 ]: Verificando ..."
sleep 2
  then
  echo "[ Prioridade IPv4 ]: OK!"
  echo "-------------------------------------------------"
  else
  echo "[ Prioridade IPv4 ]: Configurando ... "
echo "precedence ::ffff:0:0/96  100" >> /etc/gai.conf
sleep 2
  echo "[ Prioridade IPv4 ]: OK!"
  echo "-------------------------------------------------"
fi
sleep 2

if grep ^'export PATH=$PATH:/usr/local/sbin:/usr/sbin:/sbin' ~/.bashrc > /dev/null
  echo "[ Fix LDCONFIG ]: Verificando ..."
sleep 2
  then
  echo "[ Fix LDCONFIG ]: OK!"
  echo "-------------------------------------------------"
  else
  echo "[ Fix LDCONFIG ]: Configurando ... "
echo 'export PATH=$PATH:/usr/local/sbin:/usr/sbin:/sbin' >> ~/.bashrc
source /etc/profile
  echo "[ Fix LDCONFIG ]: OK!"
  echo "-------------------------------------------------"
fi
sleep 2

echo "[ Sistema ]: Atualizando ..."
apt-get update -qq 2>&1 | grep "E:"
apt-get upgrade -qqy 2>&1 | grep "E:"
systemctl daemon-reload 2>&1 | grep "E:"
apt-get --fix-broken -qq install | grep "E:"
sleep 2
echo "[ Sistema ]: OK!"
echo "-------------------------------------------------"
sleep 2
