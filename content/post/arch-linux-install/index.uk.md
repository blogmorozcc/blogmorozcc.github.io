+++
title = "Встановлення Arch Linux (UEFI + зашифрований LVM)"
date = "2024-02-24"
tags = [
    "Linux",
    "Arch",
    "Встановлення",
    "Налаштування",
]
categories = [
    "Linux",
]
image = "header.png"
+++

## Вступ

Це мій власний мануал із встановлення Arch Linux на машину з UEFI, зашифрованим LVM і окремим розділом /home.

## Кроки

Спочатку вам потрібно створити та запустити інсталяитор на вашому ПК, у результаті ви завантажитесь у звичайну консоль.

### Збільшити розмір шрифту

Оскільки більшість сучасних ноутбуків/ПК мають дисплеї з великою роздільною здатністю, я рекомендую збільшити розмір шрифту:

{{< highlight shell "linenos=false" >}}
setfont ter-132b
{{< / highlight >}}

### Налаштуйте підключення до Інтернету

У цьому прикладі використовується ПК із модемом Wi-Fi, тому я буду використовувати `iwd` для налаштування підключення до Інтернету.

Запуск iwd:

{{< highlight shell "linenos=false" >}}
iwctl
{{< / highlight >}}

Переглянути список адаптерів Wi-Fi:

{{< highlight shell "linenos=false" >}}
device list
{{< / highlight >}}

Зазвичай ви маєте бачити один пристрій Wi-Fi на виході, у моєму випадку це `wlan0`

Потім, якщо ви знаєте SSID станції та пароль, просто підключіться до станції та не забудьте замінити {SSID} своїм фактичним значенням:

{{< highlight shell "linenos=false" >}}
station wlan0 connect {SSID}
{{< / highlight >}}

Потім вийдіть із iwctl, ввівши `exit`, виконайте `ping 8.8.8.8`, щоб переконатися, що ви підключені до Інтернету.

### Синхронізувати системний годинник

{{< highlight shell "linenos=false" >}}
timedatectl set-ntp true
{{< / highlight >}}

### Розбийте диск на розділи

У моєму випадку я хочу мати окремі розділи `root`, `/boot` і `/home`, крім того, `/` і `/home` мають бути зашифровані LVM і перебувати в одній групі томів.

#### Визначте свій диск

По-перше, нам потрібно знати, який диск слід використовувати, щоб переглянути дискові пристрої:

{{< highlight shell "linenos=false" >}}
fdisk -l
{{< / highlight >}}

У моєму випадку це NVMe SSD-накопичувач `/dev/nvme0n1`.

#### Розмітка розділів

Далі скористайтеся `gdisk /dev/nvme0n1`, щоб створити розділи з таким макетом:
- `/dev/nvme0n1p1` - _принаймні 512M_ - тип `EF00` - Системний розділ EFI
- `/dev/nvme0n1p2` - _решта диска_ - тип `8309` - LUKS

#### Відформатуйте фізичні розділи

1. Розділ EFI

{{< highlight shell "linenos=false" >}}
mkfs.vfat -F 32 /dev/nvme0n1p1
{{< / highlight >}}

2. Зашифрований розділ LUKS

{{< highlight shell "linenos=false" >}}
cryptsetup luksFormat /dev/nvme0n1p2
{{< / highlight >}}

#### Створення групи томів і логічних томів

Спочатку відкрийте зашифрований контейнер:

{{< highlight shell "linenos=false" >}}
cryptsetup luksOpen /dev/nvme0n1p2 luks
{{< / highlight >}}

У результаті зашифрований розділ монтується в `/dev/mapper/luks`.

Далі розглядайте `/dev/mapper/luks` як LVM PV і створіть свої томи. У моєму випадку такі:
- Група томів `vg0`
   - Логічний том `lv_root` - Ймовірно, принаймні 20G, я використовую 75G
   - Логічний том `lv_swap` - Необов'язковий, можливо, небажаний, якщо у вас є SSD
   - Логічний том `lv_home` - Решта простору

Команди для досягнення цього:

```bash
pvcreate /dev/mapper/luks
vgcreate vg0 /dev/mapper/luks
lvcreate -L 75G -n lv_root vg0
lvcreate -L 16G -n lv_swap vg0
lvcreate -l100%FREE -n lv_home vg0 
```

#### Відформатуйте логічні томи

Я буду використовувати файлові системи ext4 для свого налаштування, тут ви можете використовувати щось інше (наприклад, btrfs).

Щоб відформатувати кореневий і домашній розділи в ext4:

```bash
mkfs.ext4 /dev/vg0/lv_root
mkfs.ext4 /dev/vg0/lv_home
```

Щоб відформатувати розділ підкачки та ввімкнути його:

```bash
mkswap /dev/vg0/lv_swap
swapon /dev/vg0/lv_swap
```

#### Монтування розділів

Цей крок потрібен для монтування створених розділів і інсталяції туди системи Arch Linux. Усі файлові системи мають бути змонтовані з урахуванням `/mnt` як кореневої файлової системи для майбутньої встановленої системи.

```bash
mount --mkdir /dev/vg0/lv_root /mnt
mount --mkdir /dev/vg0/lv_home /mnt/home
mount --mkdir /dev/nvme0n1p1 /mnt/boot
```

### Встановлення базової системи

{{< highlight shell "linenos=false" >}}
pacstrap -K /mnt base base-devel linux linux-firmware linux-headers
{{< / highlight >}}

### Створення fstab

{{< highlight shell "linenos=false" >}}
genfstab -U /mnt >> /mnt/etc/fstab
{{< / highlight >}}

### Chroot у систему

{{< highlight shell "linenos=false" >}}
arch-chroot /mnt
{{< / highlight >}}

### Створити локалізацію

Розкоментуйте `en_US.UTF-8 UTF-8` та інші необхідні локалі у файлі `/etc/locale.gen`.

Потім згенеруйте локалі:

{{< highlight shell "linenos=false" >}}
locale-gen
{{< / highlight >}}

Щоб установити локаль системи:

{{< highlight shell "linenos=false" >}}
echo "LANG=en_US.UTF-8" > /etc/locale.conf
{{< / highlight >}}

### Налаштуйте ім'я хоста

Насправді це аналог назви комп’ютера в Windows, у моєму випадку я назву його `thinkpad`.

{{< highlight shell "linenos=false" >}}
echo "thinkpad" > /etc/hostname
{{< / highlight >}}

Також додайте стандартні значення до файлу `/etc/hosts`:

```bash
# Static table lookup for hostnames.
# See hosts(5) for details.
127.0.0.1 localhost
::1 localhost

```

### Налаштування часового поясу

Мій часовий пояс `Europe/Kiev`, тому в моєму випадку має бути створено це підсумкове посилання:

{{< highlight shell "linenos=false" >}}
ln -s /usr/share/zoneinfo/Europe/Kiev /etc/localtime
{{< / highlight >}}

А також рекомендую перевести апаратний годинник BIOS на UTC:

{{< highlight shell "linenos=false" >}}
hwclock --systohc --utc
{{< / highlight >}}

### Налаштування initramfs

Встановіть пакет lvm2:

{{< highlight shell "linenos=false" >}}
pacman -S lvm2
{{< / highlight >}}

Відредагуйте файл `/etc/mkinitcpio.conf` і вставте хуки `encrypt` і `lvm2` строго в цьому порядку між хуками `block` і `filesystem`, таким чином:

{{< highlight shell "linenos=false" >}}
HOOKS=(base udev ... block encrypt lvm2 filesystems)
{{< / highlight >}}

Потім повторно згенеруйте initramfs:

{{< highlight shell "linenos=false" >}}
mkinitcpio -P
{{< / highlight >}}

### Створіть користувача та облікові дані

Спочатку рекомендується змінити пароль користувача root:

{{< highlight shell "linenos=false" >}}
passwd root
{{< / highlight >}}

Потім встановіть пакет sudo, щоб дозволити вашому користувачеві надавати привілеї:

{{< highlight shell "linenos=false" >}}
pacman -S sudo
{{< / highlight >}}

Потім відредагуйте файл sudoers:

{{< highlight shell "linenos=false" >}}
sudo EDITOR=nano visudo
{{< / highlight >}}

Розкоментуйте рядок `%wheel ALL=(ALL:ALL) ALL` і збережіть файл.

Створіть користувача, змініть пароль і додайте його в потрібні групи:

```bash
useradd -m shifthackz
passwd shifthackz
usermod -aG wheel,audio,video,storage shifthackz
```

### Встановіть необхідні пакети та робоче середовище

Це необов’язковий крок, і ви можете зробити те саме після встановлення, але я хотів би мати можливість використовувати DE після встановлення.

У цьому прикладі я встановлю Gnome DE _(на Wayland і PipeWire)_ з NetworkManager.

{{< highlight shell "linenos=false" >}}
pacman -S gnome networkmanager gnome pipewire \
 pipewire-alsa pipewire-pulse pipewire-jack \
 wireplumber bluez bluez-utils 
{{< / highlight >}}

Потім запустіть необхідні служби за замовчуванням

```bash
systemctl enable NetworkManager
systemctl enable gdm
systemctl enable bluetooth
```

### Встановіть завантажувач

Я буду використовувати systemd-boot, щоб встановити його, запустіть:

{{< highlight shell "linenos=false" >}}
bootctl install
{{< / highlight >}}

Потім створіть конфігурацію завантажувача в `/boot/loader/loader.conf`, яка містить таке:

```bash
default @saved
timeout 3
console-mode max
editor no
```

Щоб завантажити мікрокод свого ЦП на початку завантажувача, встановіть пакет `amd-ucode` або `intel-ucode`, у моєму випадку у мене процесор Intel, тому команда така:

{{< highlight shell "linenos=false" >}}
pacman -S intel-ucode
{{< / highlight >}}

Потім визначте UUID вашого зашифрованого розділу LVM (у моєму випадку /dev/nvme0n1p2):

{{< highlight shell "linenos=false" >}}
blkid /dev/nvme0n1p2
{{< / highlight >}}

Потім створіть завантажувальний запис для вашої системи Arch Linux у `/boot/loader/entries/arch.conf`, обов’язково замініть UUID і виправте кореневий розділ у параметрі `options`:

```bash
title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options cryptdevice=UUID=b574960c-1d6a-4363-bd8a-0e7345f23e06:luks root=/dev/vg0/lv_root rw

```

Нарешті перевірте bootctl і переконайтеся, що конфігурація правильна в `bootctl list`.

### Перезавантажтесь у нову систему

Для перезавантаження потрібно:
- введіть `exit`, щоб вийти з оболонки chroot.
- потім виконайте `umount -R /mnt`, щоб відмонтувати ваші розділи.
- нарешті введіть `reboot`
