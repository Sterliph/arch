#!/bin/bash

echo "Please enter root partition (example /dev/sda3): "
read ROOT

echo "Please enter Home partition (example /dev/sda3): "
read HOME

echo "Please enter windows partition (example /dev/sda3): "
read WINDOWS

echo "Please enter DVolume partition (example /dev/sda3): "
read DVOLUME

echo "Please enter root password: "
read ROOTPASS

echo "Please enter your username: "
read USER

echo "Please enter your password: "
read PASSWORD

mkfs.ext4 "${ROOT}"
mkfs.ext4 "${HOME}"

timedatectl set-ntp true
timedatectl set-timezone Europe/Moscow

# mount target
mount "${ROOT}" /mnt
mount --mkdir "$HOME" /mnt/home
mount --mkdir "$WINDOWS" /mnt/W10
mount --mkdir "$DVOLUME" /mnt/DVolume

pacstrap -K /mnt base base-devel linux linux-firmware vim

# fstab
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc

echo "ACH" > /etc/hostname
cat <<EOF > /etc/hosts
127.0.0.1       localhost
::1             localhost
127.0.1.1       ACH.localdomain    ACH
EOF

pacman -Syu
pacman -S git curl fuse3 grub networkmanager linux-headers bluez bluez-utils pulseaudio pulseaudio-bluetooth amd-ucode os-prober
sed -i 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable Networkmanager
systemctl enable bluetooth
useradd -mG wheel $USER
echo $USER:$PASSWORD | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
echo "root":${ROOTPASS} | chpasswd
cd /home/${USER}
git clone https://github.com/Sterliph/arch.git
cd /var/cache/pacman/pkg
curl https://archive.archlinux.org/repos/2024/10/31/core/os/x86_64/linux-6.11.5.arch1-1-x86_64.pkg.tar.zst -o linux-6.11.5.arch1-1-x86_64.pkg.tar.zst
curl https://archive.archlinux.org/repos/2024/10/31/core/os/x86_64/linux-6.11.5.arch1-1-x86_64.pkg.tar.zst.sig -o linux-6.11.5.arch1-1-x86_64.pkg.tar.zst.sig
curl https://archive.archlinux.org/repos/2024/10/31/core/os/x86_64/linux-headers-6.11.5.arch1-1-x86_64.pkg.tar.zst -o linux-headers-6.11.5.arch1-1-x86_64.pkg.tar.zst
curl https://archive.archlinux.org/repos/2024/10/31/core/os/x86_64/linux-headers-6.11.5.arch1-1-x86_64.pkg.tar.zst.sig -o linux-headers-6.11.5.arch1-1-x86_64.pkg.tar.zst.sig
pacman -U file://linux-6.11.5.arch1-1-x86_64.pkg.tar.zst file://linux-headers-6.11.5.arch1-1-x86_64.pkg.tar.zst
exit
umount -a
reboot
