+++
title = "Розгортання RTMP сервера для стримінгу, використовуючи Nginx RTMP"
date = "2022-07-20"
tags = [
    "Linux",
    "Сервер",
    "RTMP",
    "Nginx",
    "HLS",
    "DASH",
]
categories = [
    "Linux",
    "Мультимедіа",
]
image = "header.jpeg"
+++

## Введення

Наразі існує дуже багато платформ для онлайн-стримінгу відеоконтенту, такі як YouTube, Twitch, та інші. Для трансляції потокового відео через мережу інтернет вони використовують прокотол RTMP (Real-Time Messaging Protocol). Хоча ці платформи мають потужні можливості для проведення відеотрансляцій, в деяких випадках незалежність від стримінгової платформи та її правил є цілком доцільною.

У цій статті наведемо інструкцію з деплойменту RTMP сервіса на базі Nginx-RTMP, що дозволить приймати RTMP потік від комп'ютера стримера, та конвертувати його в сучасні формати HLS та DASH для перегляду у програмі-приймачі.

## Передумови

Для реалізації RTMP сервісу, вам потрібно мати:

- Нову віртуальну машину або фізичний сервер на базі ОС Linux.
- Комп'ютер для ведення трансляції.

Для роботи поза локальною мережею, в глобальній мережі інтернет:
- Виділену IP адресу.
- Домен.

В інструкції буде використано VPS на базі Debian 11.

## Робота з Nginx-RTMP

### Встановлення

Перш за все, необхідно встановити пакети `nginx` та `libnginx-mod-rtmp`. Для цього потрібно виконати команди:

```bash
sudo apt update
sudo apt install nginx libnginx-mod-rtmp
```

### Налаштування RTMP

Після встановлення, потрібно сконфігурувати веб-сервер Nginx таким чином, щоб він прослуховував порт 1935 для отримання RTMP-потоку. Для цього потрібно відредагувати файл `/etc/nginx/nginx.conf`:

{{< highlight shell "linenos=false" >}}
sudo nano /etc/nginx/nginx.conf
{{< / highlight >}}

В кінці файла, потрібно дописати конфігурацію RTMP сервера:

```bash
...
rtmp {
    server {
        listen 1935;
        chunk_size 4096;
        allow publish 127.0.0.1;
        allow publish 192.168.0.0/24;
        deny publish all;

        application live {
            live on;
            record off;

            hls on;
            hls_path /var/www/html/stream/hls;
            hls_fragment 3;
            hls_playlist_length 60;

            dash on;
            dash_path /var/www/html/stream/dash;
        }
    }
}
...
```

Тлумачення важливих аспектів цієї конфігурації:

- `listen 1935` - задає порт, на якому працює RTMP сервер.
- `chunk_size 4096` - задає розмір блоку, по 4 Кб.
- `allow publish [IP / Subnet]` - кожна строка вказує IP або підмережу, яким дозволено відсилати RTMP потік на сервер.
- `deny publish all` - забороняє приймати RTMP потік від всіх інших адрес/мереж.
- `application live` - конфігурація для перетворення RTMP в формати HLS та DASH, де `hls_path` та `dash_path` вказують шляхи до каталогів для розміщення плейлистів.
- `live on` - дозволяє приймати дані відеопотоком.
- `record off` - вимикає запис відеопотоку у файл на диску.

### Налаштвання HLS, DASH

Далі, необхідно розгорнути віртуальний хост, що дозволить отримувати доступ до HLS або DASH потоків через HTTP/HTTPS протокол.

Спочатку треба створити дві директорії для зберігання фрагментів відеопотоку для HLS та DASH:

```bash
sudo mkdir -p /var/www/html/stream/hls
sudo mkdir -p /var/www/html/stream/dash
```

Та також встановити власника та права:

```bash
sudo chown -R www-data:www-data /var/www/html/stream
sudo chmod -R 755 /var/www/html/stream
```

Для роботи віртуального хоста, потрібно створити новий конфігураційний файл (наприклад `rtmp`) в каталозі `/etc/nginx/sites-available`:

{{< highlight shell "linenos=false" >}}
sudo nano /etc/nginx/sites-available/rtmp
{{< / highlight >}}

Хост файл `rtmp` складається з наступного:

```bash
server {
    listen 443 ssl;
    listen 80;
    server_name rtmp.yourdomain.com;
    ssl_certificate /etc/ssl/yourdomain.crt;
    ssl_certificate_key /etc/ssl/yourdomain.key;
    ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;

    location / {
        add_header Access-Control-Allow-Origin *;
        root /var/www/html/stream;
    }
}

types {
    application/dash+xml mpd;
}
```

Пояснення до цієї конфігурації:
- Замініть `rtmp.yourdomain.com` на свій домен.
- Якщо ви хочете використовувати SSL, то також запишіть файли сертифікату та ключа за шляхами `/etc/ssl/yourdomain.crt` та `/etc/ssl/yourdomain.key`.
- Якщо ви не хочете використовувати SSL, то приберіть з файлу рядки що починаються з `ssl` та `listen 443 ssl`.

Для того щоб всі зроблені конфігурації вступили в дію, треба увімкнути віртуальний хост та перезавантажити Nginx:

```bash
sudo ln -s /etc/nginx/sites-available/rtmp /etc/nginx/sites-enabled/
sudo service nginx restart
```

## Ведення трансляції в OBS Studio

Для ведення трансляції найкраще за все підходить програма [OBS Studio](https://obsproject.com/uk).

Першочергово необхідно створити сцену, налаштувати звук, та зовнішній вигляд трансляції.

Для налаштування параметрів стримінгу, потрібно зайти в Налаштування та вибрати вкладку Stream. Там необхідно задати наступні параметри:

- Service: **Custom**
- Server: **rtmp://rtmp.yourdomain.com/live** (замість домену можна вказати IP, наприклад _http://11.22.33.44/live_)
- Stream Key: **obs_stream**

Приклад налаштувань:

![Налаштування трансляції OBS](obs_stream_settings.png)

Для запуску відеотрансляції, необхідно натиснути Start Streaming в головномі вікні програми:

![Запуск трансляції OBS](obs_stream_start.png)

## Перегляд трансляції

Тепер трансляцію можна переглянути за допомогою будь-якої програми, що підтримує протоколи HLS та DASH. Найпростішим шляхом буде перегляд у програмі VLC, відкривши посилання на потік. 

Для початку, розберемося як формується посилання на потоки в сконфігурованому сервісі:

- HLS: `{protocol}://{domain}/hls/{stream key}.m3u8`
- DASH: `{protocol}://{domain}/dash/{stream key}.mpd`

Наприлкад, якщо ви розгорнули сервіс за адресою `rtmp.yourdomain.com` що використовує SSL, та в налаштуваннях OBS вказали ключ `obs_stream`, то в такому випадку посилання будуть такими:

```
https://rtmp.yourdomain.com/hls/obs_stream.m3u8
https://rtmp.yourdomain.com/dash/obs_stream.mpd
```

Для перегляду в VLC, потрібно натиснути Ctrl + N, або перейти в меню Media > Open Network Stream, вказати посилання на один із форматів, та натиснути Play.

![Перегляд мережевого джерела в VLC](vlc_play_1.png)

## Висновки

Таким чином можна створити свій сервіс для проведення трансляцій, що буде незалежним від популярних сервісів.

Переваги такого рішення:

- Приватність та повний контроль над інфраструктурою, гарантія що дані потоку не зберігаються.
- Не потрібно дотримуватися правил сервісу (наприклад заборону транслювати певний контент).

Але є і певні недоліки:

- Таке рішення вимагає певних ресурсів сервера.
- Власнику потрібно витрачати час та кошти на обслуговування та підтримку безпеки своєї інфраструктури.
