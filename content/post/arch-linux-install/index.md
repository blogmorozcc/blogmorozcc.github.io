+++
title = "Arch Linux install guide (UEFI + encrypted LVM)"
date = "2024-02-24"
tags = [
    "Linux",
]
categories = [
    "Linux",
    "Arch",
    "Install",
    "Setup",
]
image = "header.png"
+++

## Introduction

This is my own guide for installing Arch Linux on bare metal machine with UEFI, encrypted LVM and separate /home partition.

## Steps

First you need to create and boot the installation media on your PC, as the result you will boot into plain console.

### Increase font size

As most modern laptops/PCs have large resolution displays I recommend increasing the font size:

{{< highlight shell "linenos=false" >}}
setfont ter-132b
{{< / highlight >}}

### Setup the internet connection

In this example I have a laptop with Wi-Fi modem, so I'll be using `iwd` to setup the internet connection.

Run iwd:

{{< highlight shell "linenos=false" >}}
iwctl
{{< / highlight >}}

View a list of Wi-Fi adapters

{{< highlight shell "linenos=false" >}}
device list
{{< / highlight >}}

Usually you should see one Wi-Fi device in output, in my case it is `wlan0`

Then if you know the station SSID and password, simply connect to the station, and don't forget to replace {SSID} with your actual value:

{{< highlight shell "linenos=false" >}}
station wlan0 connect {SSID}
{{< / highlight >}}

Then exit the iwctl by typing `exit`, then do the `ping 8.8.8.8` to ensure you are connected to the internet.

### Synchronize system clock

{{< highlight shell "linenos=false" >}}
timedatectl set-ntp true
{{< / highlight >}}

### Partition your disk

In my case I want to have separate `root`, `/boot` and `/home` partitions, moreover `/` and `/home` should be encrypted by LVM and be in the same volume group.

#### Detect your drive

First, we need to know what device to user, to view the disk devices use:

{{< highlight shell "linenos=false" >}}
fdisk -l
{{< / highlight >}}

In my case it is the NVMe SSD drive `/dev/nvme0n1`.

#### Partitioning

Next, use `gdisk /dev/nvme0n1` to create partitions with this layout:
- `/dev/nvme0n1p1` - _at least 512M_ - type `EF00` - EFI System Partition
- `/dev/nvme0n1p2` - _rest of disk_ - type `8309` - LUKS

#### Format the physical partitions

1. EFI Partition

{{< highlight shell "linenos=false" >}}
mkfs.vfat -F 32 /dev/nvme0n1p1
{{< / highlight >}}

2. LUKS Encrypted partition

{{< highlight shell "linenos=false" >}}
cryptsetup luksFormat /dev/nvme0n1p2
{{< / highlight >}}

#### Create volume group and logical volumes

First, open the encrypted container:

{{< highlight shell "linenos=false" >}}
cryptsetup luksOpen /dev/nvme0n1p2 luks
{{< / highlight >}}

As the result the encrypted partition is mounted at `/dev/mapper/luks`.

Next, treat `/dev/mapper/luks` as an LVM PV and create your volumes. In my case are like:

- Volume Group `vg0`
  - Logical Volume `lv_root` - Probably at least 20G, I use 75G
  - Logical Volume `lv_swap` - Optional, maybe not desirable if you have an SSD
  - Logical Volume `lv_home` - Rest of the space

The commands to achieve this:

```bash
pvcreate /dev/mapper/luks
vgcreate vg0 /dev/mapper/luks
lvcreate -L 75G -n lv_root vg0
lvcreate -L 16G -n lv_swap vg0
lvcreate -l100%FREE -n lv_home vg0 
```

#### Format the logical volumes

I will use ext4 filesystems for my setup, here you can use something different (like btrfs).

To format root and home partitions in ext4:

```bash
mkfs.ext4 /dev/vg0/lv_root
mkfs.ext4 /dev/vg0/lv_home
```

To format the swap partition and enable it:

```bash
mkswap /dev/vg0/lv_swap
swapon /dev/vg0/lv_swap
```

#### Mount the partitions

This step is required to mount the created partitions and install the Arch Linux system there. All the filesystems should be mounted considering `/mnt` as a root filesystem for the future installed system.

```bash
mount --mkdir /dev/vg0/lv_root /mnt
mount --mkdir /dev/vg0/lv_home /mnt/home
mount --mkdir /dev/nvme0n1p1 /mnt/boot
```

### Install the base system

{{< highlight shell "linenos=false" >}}
pacstrap -K /mnt base base-devel linux linux-firmware linux-headers
{{< / highlight >}}

### Generate the fstab file

{{< highlight shell "linenos=false" >}}
genfstab -U /mnt >> /mnt/etc/fstab
{{< / highlight >}}

### Chroot into your system

{{< highlight shell "linenos=false" >}}
arch-chroot /mnt
{{< / highlight >}}

### Generate locale

Uncomment `en_US.UTF-8 UTF-8` and other needed locales in file `/etc/locale.gen`.

Then generate locales:

{{< highlight shell "linenos=false" >}}
locale-gen
{{< / highlight >}}

To set the system locale:

{{< highlight shell "linenos=false" >}}
echo "LANG=en_US.UTF-8" > /etc/locale.conf
{{< / highlight >}}

### Setup the hostname

This is actually the analog of computer name in Windows, in my case I will name it `thinkpad`.

{{< highlight shell "linenos=false" >}}
echo "thinkpad" > /etc/hostname
{{< / highlight >}}

Also add the default values to the `/etc/hosts` file:

```bash
# Static table lookup for hostnames.
# See hosts(5) for details.
127.0.0.1 localhost
::1 localhost

```

### Setup TimeZone

My timezone is `Europe/Kiev`, so in my case this sumlink should be created:

{{< highlight shell "linenos=false" >}}
ln -s /usr/share/zoneinfo/Europe/Kiev /etc/localtime
{{< / highlight >}}

And also I recommend switch the BIOS hardware clock to UTC:

{{< highlight shell "linenos=false" >}}
hwclock --systohc --utc
{{< / highlight >}}

### Setup initramfs

Install the lvm2 package:

{{< highlight shell "linenos=false" >}}
pacman -S lvm2
{{< / highlight >}}

Edit the `/etc/mkinitcpio.conf` file and insert hooks `encrypt` and `lvm2` strictly in this order between the `block` and `filesystems` hooks like this:

{{< highlight shell "linenos=false" >}}
HOOKS=(base udev ... block encrypt lvm2 filesystems)
{{< / highlight >}}

Then re-generate the initramfs:

{{< highlight shell "linenos=false" >}}
mkinitcpio -P
{{< / highlight >}}

### Create a user and credntials

First it is recommended to change the root user password:

{{< highlight shell "linenos=false" >}}
passwd root
{{< / highlight >}}

Then install sudo package to allow your user grant privileges:

{{< highlight shell "linenos=false" >}}
pacman -S sudo
{{< / highlight >}}

Then edit the sudoers file:

{{< highlight shell "linenos=false" >}}
sudo EDITOR=nano visudo
{{< / highlight >}}

And uncomment the line `%wheel ALL=(ALL:ALL) ALL` and save the file.

Create a user, change the password and add it to the necessary groups:

```bash
useradd -m shifthackz
passwd shifthackz
usermod -aG wheel,audio,video,storage shifthackz
```

### Install the needed packages and desktop environment

This is optional step and you may do the same after install, but I'd like to be able to use the DE straigt after install.

In this example I will install Gnome DE _(on Wayland and PipeWire)_ with NetworkManager.

{{< highlight shell "linenos=false" >}}
pacman -S gnome networkmanager gnome pipewire \
 pipewire-alsa pipewire-pulse pipewire-jack \
 wireplumber bluez bluez-utils 
{{< / highlight >}}

Then start the needed services by default

```bash
systemctl enable NetworkManager
systemctl enable gdm
systemctl enable bluetooth
```

### Install the bootloader

I will use systemd-boot as my bootloader, to install it, run:

{{< highlight shell "linenos=false" >}}
bootctl install
{{< / highlight >}}

Then create the bootloader config at `/boot/loader/loader.conf` containing this:

```bash
default @saved
timeout 3
console-mode max
editor no
```

To load your CPU microcode early at bootloader install `amd-ucode` or `intel-ucode` package, in my case I have Intel CPU, so command is:

{{< highlight shell "linenos=false" >}}
pacman -S intel-ucode
{{< / highlight >}}

Then detect the UUID of your LVM encrypted partition (in my case /dev/nvme0n1p2):

{{< highlight shell "linenos=false" >}}
blkid /dev/nvme0n1p2
{{< / highlight >}}

Then create the boot entry for your Arch Linux system at `/boot/loader/entries/arch.conf`, make sure to replace the UUID and correct root partition in the `options` parameter:

```bash
title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options cryptdevice=UUID=b574960c-1d6a-4363-bd8a-0e7345f23e06:luks root=/dev/vg0/lv_root rw

```

Finally check the bootctl and validate that the config is correct in `bootctl list`.

### Reboot to your new system

To reboot you need:
- type `exit` to exit the chroot shell.
- then do `umount -R /mnt` to unmount your partitions.
- finally type `reboot`