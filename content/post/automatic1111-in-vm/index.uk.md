+++
title = "Запуск Stable Diffusion у віртуальній машині на відеокарті AMD (AUTOMATIC1111 + KVM + GPU Passthrough)"
date = "2024-06-01"
tags = [
    "AUTOMATIC1111",
    "Stable Diffusion",
    "KVM",
    "AMD",
    "ROCM",
    "GPU",
    "Virtio",
    "Ubuntu Server",
]
categories = [
    "Linux",
    "Обладнання",
    "Штучний Інтелект",
    "Віртуалізація",
]
image = "header.png"
+++

## Вступ 

Stable Diffusion — це модель глибокого навчання з текстом у зображення, розроблена Stability AI, що використовується для створення детальних зображень на основі текстових підказок. Модель належить до класу генеративних моделей, званих дифузійними моделями, які ітеративно знімають шум у випадковому сигналі для отримання зображення. AUTOMATIC1111 відноситься до популярної реалізації веб-інтерфейсу користувача (UI) для взаємодії із Stable Diffusion. Він забезпечує надійний і зручний спосіб використання можливостей Stable Diffusion.

### Чому я запускаю AUTOMATIC1111 у віртуальній машині

В одній із моїх попередніх статей я згадав, що використовую ПК з двома відеокартами AMD, використовує Arch Linux в якості основної ОС. Особисто для мене запуск AUTOMATIC1111 у віртуальній машині на базі KVM із прокиданням відеокарти AMD має кілька ключових переваг:

1. **Портативність**. Оскільки я використовую Arch Linux як свою основну хост-ОС на різних комп’ютерах, інколи буває складно керувати залежностями, необхідними для запуску AUTOMATIC1111. Наприклад, на момент написання цієї статті (02.06.2024) для AUTOMATIC1111 потрібен Python 3.10, а найновішою версією Python в офіційних репозиторіях arch є Python 3.12. У разі запуску AUTOMATIC1111 усередині віртуальної машини я можу налаштувати залежності всередині цієї віртуальної машини, і мені не потрібно турбуватися про те, що залежності потенційно стануть некоректними після оновлення Arch.

2. **Резервне копіювання**. Оскільки я маю сховище віртуальної машини як один файл *.qcow2, я можу створити його резервну копію, перенести на іншу машину чи сервер у своїй домашній лабораторії. Також легко зберігати файли AI моделей та LORA в cховищі віртуальної машини, і якщо мені потрібно перенести інсталяцію AUTOMATIC1111 на іншу реальну машину, мені потрібно лише скопіювати резервну копію віртуальної машини. Немає необхідності кожного разу встановлювати залежності, налаштовувати моделі.

### Для чого мені потрібен AUTOMATIC1111

![](https://github.com/ShiftHackZ/Stable-Diffusion-Android/raw/master/docs/assets/github-header-image.png)

Програмне забезпечення AUTOMATIC1111 дуже важливе для моєї роботи, оскільки я розробляю безкоштовний open soruce додаток [SDAI - Android Stable Diffusion](https://github.com/ShiftHackZ/Stable-Diffusion-Android), який можна підключати до будь-якого сервера AUTOMATIC1111 або іншого підтримуваного провайдера генерації зображень. Мені потрібно багато різних ізольованих віртуальних серверів AUTOMATIC1111 для тестування мого Android додатку.

## Встановлення

### Створення нової віртуальної машини Linux

Спочатку нам потрібно створити нову віртуальну машину Linux із пропуском GPU пристроїв PCI до цієї віртуальної машини. Я вже розповідав про створення віртуальної машини в статті "[GPU PCI passthrough to Windows KVM on Arch Linux](https://blog.moroz.cc/uk/post/прокидання-відеокарти-pci-до-windows-kvm-на-arch-linux/#налаштування-нової-віртуальної-машини-та-установка-windows-1011)", але цього разу я використовуватиму [Ubuntu Sever 22.04 LTS](https://releases.ubuntu.com/22.04/) як ОС для гостьової ВМ. Я вибрав Ubuntu Server 22.04 для гостьової ОС, тому що на момент написання цієї статті (02.06.2024) це остання версія, яка підтримується пропрієтарним драйвером AMD ROCM, який необхідний для запуску штучного інтелекту на потужності GPU.

### Оновіть пакети ОС

Після встановлення ОС перше, що вам потрібно зробити, це оновити системні пакети до останніх доступних версій.

```bash
sudo apt update
sudo apt upgrade
```

### Встановіть необхідні пакети

{{< highlight shell "linenos=false" >}}
sudo apt install -y git python3-pip python3-venv python3-dev libstdc++-12-dev libgl1-mesa-glx
{{< / highlight >}}

### Встановлення драйвера AMD ROCM

Я використав офіційні інструкції з [документації AMD](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/tutorial/quick-start.html), щоб встановити драйвер ROCM.

Спочатку встановіть заголовки та додаткові компоненти для поточного ядра:

{{< highlight shell "linenos=false" >}}
sudo apt install -y "linux-headers-$(uname -r)" "linux-modules-extra-$(uname -r)"
{{< / highlight >}}

Потім переконайтеся, що ваш поточний користувач включений до груп `video` і `render`. Щоб додати поточного користувача до груп, використовуйте команду:

{{< highlight shell "linenos=false" >}}
sudo usermod -a -G render,video $LOGNAME
{{< / highlight >}}

Завантажте інсталяційний пакет deb і встановіть його:

{{< highlight shell "linenos=false" >}}
wget https://repo.radeon.com/amdgpu-install/6.1.1/ubuntu/jammy/amdgpu-install_6.1.60101-1_all.deb
sudo dpkg -i amdgpu-install_6.1.60101-1_all.deb
{{< / highlight >}}

Встановіть модуль DKMS і пакети rocm:

{{< highlight shell "linenos=false" >}}
sudo apt update
sudo apt install amdgpu-dkms rocm
{{< / highlight >}}

Нарешті, перезавантажте віртуальну машину:

{{< highlight shell "linenos=false" >}}
sudo reboot
{{< / highlight >}}

### Встановлення AUTOMATIC1111

Найпростіший і зручний спосіб - просто клонувати офіційний репозиторій git. Після клонування перейдіть до клонованого каталогу.

{{< highlight shell "linenos=false" >}}
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui
cd stable-diffusion-webui
{{< / highlight >}}

Налаштуйте віртуальне середовище Python:

{{< highlight shell "linenos=false" >}}
python3 -m venv venv
source venv/bin/activate
{{< / highlight >}}

Встановіть залежності python, необхідні AUTOMATIC1111:

{{< highlight shell "linenos=false" >}}
pip3 install -r requirements.txt
{{< / highlight >}}

Видаліть стандартні залежності torch та замініть їх на ROCM:

{{< highlight shell "linenos=false" >}}
pip3 uninstall torch torchvision
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.0
{{< / highlight >}}

### Створіть скрипт запуску AUTOMATIC1111

Я буду використовувати nano для створення нового файлу `nano launch.sh`.

```bash
#!/bin/sh

source venv/bin/activate

export HSA_OVERRIDE_GFX_VERSION=10.3.0
export HIP_VISIBLE_DEVICES=0
export PYTORCH_HIP_ALLOC_CONF=garbage_collection_threshold:0.8,max_split_size_mb:512

python3 launch.py --api --listen --enable-insecure-extension-access --opt-sdp-attention
```

Потім збережіть файл `Ctrl + O` і вийдіть з nano `Ctrl + X`.

### Запуск AUTOMATIC1111

Кожного разу, коли вам потрібно запустити AUTOMATIC1111, перейдіть до склонованого каталогу `stable-diffusion-webui` і запустіть створений сценарій `launch.sh`, як у наступному прикладі:

{{< highlight shell "linenos=false" >}}
cd stable-diffusion-webui
bash launch.sh
{{< / highlight >}}

У результаті ви побачите, що AUTOMATIC1111 працює.

![Запущений інстанс AUTOMATIC1111.](a1111-launch.png)

## Висновок

Stable Diffusion — це потужна модель для створення зображень із текстових описів, а AUTOMATIC1111 — це зручний інтерфейс, який полегшує ефективне використання можливостей Stable Diffusion. Разом вони забезпечують широкий спектр творчих і практичних застосувань у сфері генеративного мистецтва та синтезу зображень. Використовуючи віртуальну машину на основі KVM із прокинутим графічним адаптером AMD, ви можете створити потужне, безпечне та гнучке середовище для запуску AUTOMATIC1111 і ефективного використання можливостей Stable Diffusion.

## Посилання

- [Ubuntu Sever 22.04 LTS Jammy](https://releases.ubuntu.com/22.04/)
- [AMD ROCM Документація](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/tutorial/quick-start.html)
- [AUTOMATIC1111](https://github.com/AUTOMATIC1111/stable-diffusion-webui)
- [SDAI - Stable Diffusion Android додаток](https://github.com/ShiftHackZ/Stable-Diffusion-Android)
- [Кастомний скрипт запуску stable-diffusion-webui](https://gist.github.com/evshiron/8cf4de34aa01e217ce178b8ed54a2c43)
