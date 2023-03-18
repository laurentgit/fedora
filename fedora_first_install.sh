#!/bin/bash

##############################################################################
#                               Variables                                    #
##############################################################################


##############################################################################
#                               Functions                                    #
##############################################################################

verif_user(){
# Vérification de base pour éxécuter le script
if [[ $EUID -ne 0 ]]; then
   echo "Ce script doit être executer par le user root" 1>&2
   exit 1
fi
}

dnf_configuration(){
# Paramétrage DNF
echo "fastestmirror=true" >> /etc/dnf/dnf.conf
echo "max_parallel_downloads=10" >> /etc/dnf/dnf.conf
echo "countme=false" >> /etc/dnf/dnf.conf
echo "deltarpm=0" >> /etc/dnf/dnf.conf
# Optionnal, can be useful for some updates, remove # if needed
# echo "## Exclude following Packages Updates ##"  >> /etc/dnf/dnf.conf
# echo "exclude=mesa-va-drivers"  >> /etc/dnf/dnf.conf
}

update_upgrade(){
# Clean Cache DNF
dnf clean all
dnf upgrade -y
}

firmawre_update(){
# MàJ Firmware si supporté
fwupdmgr refresh
fwupdmgr get-updates && fwupdmgr update
}

add_rpmfusion(){
# Install RPM Fusion
dnf install -y --nogpgcheck https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf install -y rpmfusion-free-appstream-data rpmfusion-nonfree-appstream-data 
dnf install -y rpmfusion-free-release-tainted rpmfusion-nonfree-release-tainted
}

add_codecs(){
# Install Codecs
dnf install -y gstreamer1-plugins-{base,good,bad-free,good-extras,bad-free-extras,ugly-free} gstreamer1-libav
dnf install -y gstreamer1-plugins-{bad-freeworld,ugly}
dnf install -y libdvdcss
}

add_amd_codecs_mesa(){
# Install accélération vidéo
dnf -y swap mesa-va-drivers mesa-va-drivers-freeworld
dnf -y swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
}

install_flatpak_remote(){
# Install Flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}

add_mandatory_software(){
dnf install -y gnome-tweaks file-roller file-roller-nautilus vim git vlc
}

add_kvm(){
dnf install -y @virtualization
usermod -aG libvirt laurent
}

clean_pre_install(){
dnf autoremove -y gnome-software PackageKit abrt* gnome-boxes
}

google_chrome_install(){
dnf install -y fedora-workstation-repositories
dnf config-manager --set-enabled google-chrome
dnf install -y google-chrome-stable
}

##############################################################################
#                            Main function                                   #
##############################################################################

verif_user
dnf_configuration
clean_pre_install
update_upgrade
firmawre_update
add_rpmfusion
add_codecs
add_amd_codecs_mesa
install_flatpak_remote
add_mandatory_software
add_kvm
google_chrome_install

