sudo apt install -y cpu-checker
sudo kvm-ok

sudo apt-get install -y qemu-kvm qemu-user-static qemu-utils bridge-utils dnsmasq virt-manager libvirt-clients libvirt-daemon-system libguestfs-tools libosinfo-bin ovmf virtinst
sudo systemctl start libvirtd
sudo systemctl enable libvirtd

sudo apt-get install network-manager -y
sudo modprobe vhost_net

sudo usermod -aG libvirt $USER
sudo usermod -aG libvirt root

sudo sed -i 's|#uri_default = "qemu:///system"|uri_default = "qemu:///system"|g' /etc/libvirt/libvirt.conf

virsh --connect=qemu:///system net-autostart default

sudo modprobe vhost_net

cat >> /etc/modules << EOL
vhost_net
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd

## options vfio-pci ids=XXXX:XXXX, YYYY:YYYY
## Para adicionar o ID do PCI para passtrough, use o comando "lspci -nn" para listar os dispositivos, as ids estão entre cochetes "[]".
## Copie e cole em "options vfio-pci ids=XXXX:XXXX que são a numeração coletadas acima, separadas por virgula cada dispositivo.
## Para listar os dispositivos adicionados ao IOMMU, digite o comando: "journalctl -b 0 | grep -i iommu"
EOL

cat >> etc/initramfs-tools/modules << EOL
virtio_pci
virtio_blk
EOL

update-initramfs -u

sudo sed -i 's|GRUB_CMDLINE_LINUX_DEFAULT="quiet"|GRUB_CMDLINE_LINUX_DEFAULT="quiet preempt=voluntary iommu=pt amd_iommu=on intel_iommu=on"|g' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo update-initramfs -c -k $(uname -r)
sudo update-grub

BRIDGE_NAME=br0
PHYSICAL_INTERFACE=$(ip -4 a | grep $(hostname -I | cut -d ' ' -f 1) | grep -o '[^ ]*$')   # Nome da interface de rede física, ajuste conforme sua configuração

# Verificar se o script está rodando como root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script precisa ser executado como root."
    exit 1
fi

# Instalar pacotes necessários
apt update
apt install -y bridge-utils ifupdown

# Criar backup do arquivo de configuração de rede
cp /etc/network/interfaces /etc/network/interfaces.bak

# Configuração do bridge no arquivo /etc/network/interfaces
echo "Configurando o bridge $BRIDGE_NAME..."

cat <<EOF > /etc/network/interfaces
# Interface loopback
auto lo
iface lo inet loopback

# Configuração da interface física para o bridge
auto $PHYSICAL_INTERFACE
iface $PHYSICAL_INTERFACE inet manual
    up ip link set dev $PHYSICAL_INTERFACE up
    down ip link set dev $PHYSICAL_INTERFACE down

# Configuração do bridge
auto $BRIDGE_NAME
iface $BRIDGE_NAME inet dhcp
    bridge_ports $PHYSICAL_INTERFACE
    bridge_fd 0
    bridge_maxwait 0
EOF

# Reiniciar a rede para aplicar as configurações
echo "Reiniciando a rede..."
systemctl restart networking

# Verificar se o bridge foi criado com sucesso
brctl show

echo "Bridge $BRIDGE_NAME configurado com sucesso!"

mkdir /opt/ISO
wget -P /opt/ISO https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.266-1/virtio-win.iso
echo "Foi realizado o download dos drives do VirtIO para Windows na pasta /opt/ISO"
echo "Anexe na unidade de CD-ROM e instale os drivers de rede no nas VMS Windows"

# Check os drivers em uso do Kernel com o comando: "lspci -vnn"
# Depois crie o arquivo para desativar os drvers da inicialização do kernel

# cat <<"EOF">> /etc/modprobe.d/vfio.conf
# softdep nouveau pre: vfio-pci
# softdep snd_hda_intel pre: vfio-pci
# options vfio-pci ids=XXXX:XXXX,YYYY:YYYY
# EOF
# sudo update-initramfs -u

# Depois, pré-check os drivers em uso do Kernel com o comando: "lspci -vnn" e verifique se "vfio-pci" aparece em uso para os dispostivos selecionados.
# Fonte: https://gist.github.com/nephest/c2d2c31417be545c3c6eef2cec0e796e

# Fonte: https://github.com/small-hack/smol-gpu-passthrough

###################################################################################
## Teste IOMMU support pelo Windows via powershell
## (Get-VMHost).IovSupport; (Get-VMHost).IovSupportReasons
## get-vmswitch | fl *iov*
## Get-VM | Format-List -Property *

## https://www.youtube.com/watch?v=g--fe8_kEcw

## cat <<'EOF'>> /etc/modprobe.d/vfio.conf
## options vfio-pci ids=10de:1f99,10de:10fa
## softdep nvidia pre: vfio-pci
## EOF

## lspci -k | grep -E "vfio-pci|NVIDIA"

## wget -P /opt/ https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
