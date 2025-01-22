DEBIAN_VERSION_CODENAME=$(cat /etc/*release* | grep VERSION_CODENAME | cut -d '=' -f 2)

mkdir -pm755 /etc/apt/keyrings
wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/stable/winehq-$(cat /etc/*release* | grep VERSION_CODENAME | cut -d '=' -f 2).sources

dpkg --add-architecture i386
apt update && apt upgrade -y && systemctl daemon-reload

apt install -y --install-recommends winehq-stable winetricks mono-complete winbind ttf-mscorefonts-installer 
apt install -y --install-recommends libc6-i386 zlib1g libx11-6 libxft2 libcairo2 libvulkan1 vulkan-tools libvulkan1:i386 libmpg123-dev libwine fonts-wine libvkd3d1 libz-mingw-w64 libwine wine-binfmt binfmt-support wine64-preloader wine64-tools
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections

sudo -u $USER winetricks forcemono

mkdir /opt/wine/
mkdir /opt/wine/downloads

wget -P /opt/wine/downloads https://dl.winehq.org/wine/wine-mono/9.4.0/wine-mono-9.4.0-x86.msi
sudo -u $USER wine msiexec -i /opt/wine/downloads/wine-mono-9.4.0-x86.msi

wget -P /opt/wine/downloads https://dl.winehq.org/wine/wine-gecko/2.47.4/wine-gecko-2.47.4-x86_64.msi
sudo -u $USER wine msiexec -i /opt/wine/downloads/wine-gecko-2.47.4-x86_64.msi

sudo -u $USER winetricks dxvk d3dx9 directx9 corefonts xinput dxdiagn devenum msxml3 msxml6 mfc140 directplay dsound mimeassoc=on windowscodecs

sudo -u $USER wine winecfg -v=win10 wineboot -u -f -r

wget -P /opt/wine/downloads https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe
sudo -u $USER wine /opt/wine/downloads/mt5setup.exe /auto

sudo -u $USER wine cmd.exe /c "$(find / | grep terminal64.exe)"

#sudo -u $USER winetricks dxvk d3dx9 directx9 dotnet48 vcrun2012 vcrun2015 corefonts xinput windowscodecs msxml3 msxml6 mfc140
