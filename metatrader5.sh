DEBIAN_VERSION_CODENAME=$(cat /etc/*release* | grep VERSION_CODENAME | cut -d '=' -f 2)

apt install sudo wget -y

sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/$(cat /etc/*release* | grep VERSION_CODENAME | cut -d '=' -f 2)/winehq-$(cat /etc/*release* | grep VERSION_CODENAME | cut -d '=' -f 2).sources

sudo apt update

sudo dpkg --add-architecture i386 
apt install -y --install-recommends winehq-stable winetricks mono-complete winbind ttf-mscorefonts-installer
apt install -y --install-recommends libc6:i386 zlib1g:i386 libx11-6:i386 libxft2:i386 libcairo2:i386 libvulkan1:{amd64,i386}
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections

apt-get install apt-transport-https software-properties-common unzip make cmake gcc dirmngr gnupg gnupg2 gnupg1 build-essential -y
apt-get --no-install-recommends install xorg lightdm lxde-core xrdp -y

wget https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe


wget -P /opt/ https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5debian.sh
chmod +x /opt/mt5debian.sh

# WINEPREFIX=~/.mt5 winecfg -v=win10
# WINEPREFIX="$HOME/.wine" WINEARCH=win32 wine wineboot

# mkdir /opt/wineprofile/
# mkdir /opt/wineprofile/$USER
# WINEPREFIX="/opt/wineprofile/$USER/.wine" WINEARCH=win32 wine winecfg -v=win10 wineboot -u -f -r

#WINEPREFIX="/opt/wineprofile/$USER/.wine" WINEARCH=win32 wine wineboot winecfg -v=win10
# WINEPREFIX=~"/opt/wineprofile/$USER/.wine" winecfg -v=win10

# winetricks dxvk d3dx9 


mv /etc/xdg/lxsession/LXDE/autostart /etc/xdg/lxsession/LXDE/autostart.bkp

cat << 'EOF' > /etc/xdg/lxsession/LXDE/autostart
#Scrpit do Painel Inicial
#Desativa bloqueio automático de tela, proteção de tela
@xset s noblack
@xset s off
@xset -dpms
EOF

mv /etc/xdg/openbox/menu.xml /etc/xdg/openbox/menu.xml.bkp
# Criando no arquivo menu.xml
cat << 'EOF' > /etc/xdg/openbox/menu.xml
<?xml version="1.0" encoding="UTF-8"?>
 <openbox_menu xmlns="http://openbox.org/"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://openbox.org/
  file:///usr/share/openbox/menu.xsd">
  <menu id="root-menu" label="Openbox 3">
      <item label="Instalar MT5">
        <action name="Execute"><execute>sh /opt/./mt5debian.sh</execute></action>
      </item>
    <separator />
      <item label="Metatrader 5">
        <action name="Execute"><execute>wine /home/user/.mt5/drive_c/Program\ Files/MetaTrader\ 5/terminal64.exe</execute></action>
      </item>
    <separator />
      <item label="Sair">
        <action name="Execute"><execute>bash -c "pkill -KILL -u $USER"</execute></action>
      </item>   
  </menu>
</openbox_menu>
EOF

sudo reboot
