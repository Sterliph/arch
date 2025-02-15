#!/bin/bash

echo "Please enter Root(/) paritition: (example /dev/sda3)"
read ROOT

echo "Please enter Home(/home) paritition: (example /dev/sda3)"
read HOME

echo "Please enter W10(/W10) paritition: (example /dev/sda3)"
read WINDOWS

echo "Please enter DVolume(/DVolume) paritition: (example /dev/sda3)"
read DVOLUME

echo "Please enter root password"
read ROOTPASS

echo "Please enter your Username"
read USER

echo "Please enter your Password"
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

pacstrap /mnt base base-devel linux linux-firmware vim --noconfirm --needed

# fstab
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

ln -sf /usr/share/zoneinfo/Asia/Kathmandu /etc/localtime
hwclock --systohc

echo "ACH" > /etc/hostname
cat <<EOF > /etc/hosts
127.0.0.1       localhost
::1                     localhost
127.0.1.1       ACH.localdomain    ACH
EOF

pacman -S fuse3 grub networkmanager linux-headers bluez bluez-utils pulseaudio pulseaudio-bluetooth amd-ucode os-prober --noconfirm --needed
sed -i 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable Networkmanager
systemctl enable bluetooth
useradd -mG wheel $USER
echo $USER:$PASSWORD | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
echo "root":ROOTPASS | chpasswd
exit
umount -a
reboot