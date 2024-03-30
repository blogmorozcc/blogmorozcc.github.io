+++
title = "Встановлення кастомного ядра Linux ZEN на Arch Linux для покращення швидкодії системи"
date = "2024-03-25"
tags = [
    "Linux",
    "Ядро",
    "Zen",
]
categories = [
    "Linux",
]
image = "header.png"
+++

## Що таке Linux Zen Kernel?

Ядро Linux Zen Kernel — це модифікована версія ядра Linux, яка зосереджена на забезпеченні покращеної продуктивності, швидкості реагування та гнучкості для користувачів настільних комп’ютерів і робочих станцій. Він розроблений і підтримується проектом Zen Kernel, метою якого є оптимізація ядра для настільних комп’ютерів.

Ядро Zen містить різні виправлення та оптимізації, спрямовані на зменшення латентності, покращення реагування системи та підвищення загальної продуктивності системи. Ці оптимізації можуть включати налаштування планувальника (scheduler), покращення планувальника вводу-виводу (IO scheduler), покращення планування ЦП та інші налаштування, пов’язані з продуктивністю.

Користувачі, які надають перевагу продуктивності та швидкодії робочого столу чи робочої станції, можуть вибрати використання ядра Linux Zen замість стандартного ядра Linux, яке надається їхнім дистрибутивом. Однак важливо зазначити, що Zen Kernel є модифікацією сторонніх розробників і може офіційно підтримуватися не всіма дистрибутивами Linux. Користувачі, які бажають випробувати Zen Kernel, повинні переглянути документацію та інструкції, надані проектом Zen Kernel або спільнотою свого конкретного дистрибутива.

## Основні переваги

Ключові функції та оптимізації, що містяться в ядрі Linux Zen, включають такі основні переваги:

- Набір патчів для зменшення затримки: ці патчі спрямовані на зменшення затримки ядра, покращення реагування, що особливо важливо для інтерактивного використання робочого столу, обробки звуку та ігор.

- Планувальник вводу-виводу BFQ: ядро Zen часто містить планувальник вводу-виводу BFQ (Budget Fair Queueing), який визначає пріоритетність запитів вводу-виводу на основі процесу, який їх генерує, з метою забезпечення більш плавної роботи системи, особливо під час багатозадачності або під час роботи. з інтерактивними додатками.

— Додаткові планувальники ЦП: у деяких випадках ядро Zen включає альтернативні алгоритми планування ЦП або оптимізації для покращення продуктивності багатозадачності та швидкості реагування.

- Підтримка випередження та реального часу: ядро може включати виправлення для покращення можливостей випередження та реального часу, зменшення затримок та покращення реагування на чутливі до часу завдання.

— Оптимізації за замовчуванням: деякі параметри ядра налаштовано за замовчуванням, щоб краще відповідати робочому навантаженню робочого столу та мультимедіа.

- Стабільність і надійність: наголошуючи на покращенні продуктивності, розробники ядра Zen зазвичай забезпечують підтримку стабільності та надійності, хоча користувачі завжди повинні знати, що будь-які модифікації ядра можуть становити ризик.

## Встановлення (Arch Linux)

Ядро Linux Zen включено в менеджер пакетів Arch Linux pacman і може бути легко встановлено за допомогою pacman:

{{< highlight shell "linenos=false" >}}
sudo pacman -S linux-zen linux-zen-headers
{{< / highlight >}}

Після цього ядро фактично буде встановлено у вашій системі, але тепер настав час налаштувати завантажувач (bootloader) на завантаження з ядром Linux Zen Kernel замість стандартного. Це може залежати від вашого завантажувача, у моєму випадку я використовую `systemd-boot`.

Записи завантаження знаходяться в каталозі `/boot/loader/entries`, тому перейдіть туди:

{{< highlight shell "linenos=false" >}}
cd /boot/loader/entries/
{{< / highlight >}}

І виведіть в термінал всі ваші записи для завантаження:

{{< highlight shell "linenos=false" >}}
ls -la
{{< / highlight >}}

У моєму випадку я маю лише один запис `arch.conf`:

```bash
drwxr-xr-x 2 root root 4096 Feb 24 14:42 .
drwxr-xr-x 3 root root 4096 Mar 25 20:15 ..
-rwxr-xr-x 1 root root  208 Mar 18 18:31 arch.conf
```

Я рекомендую залишити оригінальний запис завантаження (boot entry) та оригінальне ядро Linux для резервної копії, тож якщо нове ядро не завантажиться, ви завжди матимете можливість завантажитися зі стандартного ядра у завантажувачі.

Створіть дублікат початкового файлу запису завантаження:

{{< highlight shell "linenos=false" >}}
sudo cp arch.conf arch-zen.conf
{{< / highlight >}}

Потім відредагуйте файл `arch-zen.conf` за допомогою обраного вами текстового редактора, у моєму випадку я використовую nano таким чином:

{{< highlight shell "linenos=false" >}}
sudo nano arch-zen.conf
{{< / highlight >}}

Потім змініть конфігурацію та замініть 3 параметри (title, linux, initrd) відповідно до прикладу вище:

Раніше (оригінальний файл `arch.conf`):

```bash
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
```

Після (змінити у файлі `arch-zen.conf`):

```bash
title Arch Linux Zen
linux /vmlinuz-linux-zen
initrd /initramfs-linux-zen.img
```

Після збереження файлу перезавантажте систему та виберіть `Arch Linux Zen` під час завантаження.

## Висновки

Підводячи підсумок, ядро Linux Zen створено для користувачів, які надають перевагу швидкості реагування робочого столу, мультимедійній продуктивності та іграм. Однак користувачі повинні ретельно оцінити, чи відповідають конкретні оптимізації та виправлення, надані ядром Zen, їхнім потребам і вподобанням, оскільки деякі функції можуть послабити продуктивність загального призначення або сумісність для спеціальних випадків використання.