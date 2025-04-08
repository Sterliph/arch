#!/bin/bash

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -sri
cd ..
rm -rf yay

sudo sed -i "s/^#[multilib]/[multilib]/" /etc/pacman.conf
sudo sed -i "s/^#Include = /etc/pacman.d/mirrorlist/Include = /etc/pacman.d/mirrorlist/" /etc/pacman.conf
sudo sed -i "s/^#IgnorePkg   =/IgnorePkg   = linux linux-headers/" /etc/pacman.conf
echo "alias 'bt=bluetoothctl'" >> ~/.bashrc

yay -Syu
sudo pacman -Syu

yay -S nvidia-390xx-dkms nvidia-390xx-utils lib32-nvidia-390xx-utils nvidia-settings

sudo rm /etc/default/grub
sudo mv grub /etc/default/

sudo rm /etc/mkinitcpio.conf
sudo mv mkinitcpio.conf /etc/

sudo mkdir -p /etc/pacman.d/hooks/ && sudo mv ./nvidia.hook /etc/pacman.d/hooks/

sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo mkinitcpio -P

cd ~/arch
mkdir pkgs
mkdir ~/Desktop
cd pkgs

curl https://archive.archlinux.org/repos/2024/10/31/core/os/x86_64/linux-6.11.5.arch1-1-x86_64.pkg.tar.zst -o linux-6.11.5.arch1-1-x86_64.pkg.tar.zst
curl https://archive.archlinux.org/repos/2024/10/31/core/os/x86_64/linux-6.11.5.arch1-1-x86_64.pkg.tar.zst.sig -o linux-6.11.5.arch1-1-x86_64.pkg.tar.zst.sig
curl https://archive.archlinux.org/repos/2024/10/31/core/os/x86_64/linux-headers-6.11.5.arch1-1-x86_64.pkg.tar.zst -o linux-headers-6.11.5.arch1-1-x86_64.pkg.tar.zst
curl https://archive.archlinux.org/repos/2024/10/31/core/os/x86_64/linux-headers-6.11.5.arch1-1-x86_64.pkg.tar.zst.sig -o linux-headers-6.11.5.arch1-1-x86_64.pkg.tar.zst.sig

sudo cp * /var/cache/pacman/pkg
cd /var/cache/pacman/pkg
sudo pacman -U file://linux-6.11.5.arch1-1-x86_64.pkg.tar.zst file://linux-headers-6.11.5.arch1-1-x86_64.pkg.tar.zst

cd ~/arch
mv pkgs ~/Desktop

sudo pacman -S xorg xorg-server xorg-xinit bspwm sxhkd rofi noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-liberation alacritty polybar pavucontrol  7zip mpv qbittorrent libreoffice-still htop flameshot feh telegram-desktop spotify-launcher
yay -S google-chrome v2rayn

tar -xvf .config.tar
mv .config ~/
mv .xinitrc ~/

cd ..
rm -rf arch