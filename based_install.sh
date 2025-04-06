#!/bin/bash

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -sri
cd ..
rm -rf yay

sed -i "s/^#[multilib]/[multilib]/" /etc/pacman.conf
sed -i "s/^#Include = /etc/pacman.d/mirrorlist/Include = /etc/pacman.d/mirrorlist/" /etc/pacman.conf
sed -i "s/^#IgnorePkg   =/IgnorePkg   = linux linux-headers/" /etc/pacman.conf
echo "alias 'bt=bluetoothctl'" >> ~/.bashrc

yay -Syu

yay -S nvidia-390xx-dkms nvidia-390xx-utils lib32-nvidia-390xx-utils nvidia-settings

rm /etc/default/grub
mv ../grub /etc/default/

rm /etc/mkinitcpio.conf
mv ../mkinitcpio.conf /etc/

grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -P

pacman -S xorg xorg-server xorg-xinit bspwm sxhkd rofi noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-liberation alacritty polybar pavucontrol  7zip mpv qbittorrent libreoffice-still htop flameshot feh telegram-desktop spotify-launcher
yay -S google-chrome v2rayn

mv .config ~/
mv .xinitrc ~/

cd ..
rm -rf arch
reboot
