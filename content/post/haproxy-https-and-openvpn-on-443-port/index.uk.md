+++
title = "Запуск HTTPS і OpenVPN на одному порту 443 за допомогою балансувальника навантаження HAProxy"
date = "2024-06-07"
tags = [
    "HAProxy",
    "VPN",
    "OpenVPN",
    "Балансування навантаження",
    "HTTPS",
    "SSL Termination",
    "Мережевий трафік",
    "Веб-сервер",
]
categories = [
    "Linux",
    "Мережі",
    "Кібер-безпека",
]
image = "header.png"
+++

## Вступ

### Які причини для запуску OpenVPN і веб-сервера на одному порту 443

Уявімо, що у вас є сервер OpenVPN, який слухає порт 1194, і ви підключаєтеся з публічної або робочої мережі, яку ви не контролюєте. У цьому випадку може виникнути ситуація, коли дозволені лише вихідні підключення до загальних портів (наприклад, 80 і 443, щоб користувач міг лише переглядати веб-сторінки), тому ви не можете підключитися до свого сервера OpenVPN і зашифрувати трафік від адміністратора мережі.

У цьому конкретному випадку ви можете спробувати перемістити службу OpenVPN для прослуховування через порт 443. Але що робити, якщо ви також використовуєте свій сервер для розміщення деяких веб-сайтів, тому порт 443 уже використовується? Щоб вирішити цю проблему, доцільно використовувати проксі-сервер або рішення для балансування навантаження та перенаправляти мережевий трафік із вхідного порту 443 на відповідний порт локальної служби 1194, 8080 тощо.

### Як це працює

Ви можете налаштувати HAProxy на завершення SSL, а потім маршрутизацію трафіку на основі SNI (Індикація імені сервера) або інших критеріїв на ваш сервер OpenVPN або на інші веб-сайти. Ось загальний огляд того, як цього досягти:

1. **Завершення SSL:** HAProxy оброблятиме вхідні з’єднання SSL на порту 443. Він розшифровуватиме трафік, перевірятиме його, а потім вирішуватиме, куди його пересилати.

2. **Маршрутизація трафіку:** На основі таких критеріїв, як запитане ім’я хоста або вміст початкових пакетів, HAProxy може скеровувати трафік на різні внутрішні сервери:

- Трафік HTTPS можна перенаправляти на ваші веб-сервери.
- Трафік OpenVPN можна перенаправляти на сервер OpenVPN.

3. **Приховування VPN-трафіку:** Завдяки обслуговуванню OpenVPN на порту 443 мережевим адміністраторам стає важче відрізнити звичайний трафік HTTPS від трафіку VPN. Це може допомогти в середовищах, де використання VPN обмежено або контролюється.

## Налаштування 

Посібник зі встановлення припускає, що ви вже запустили ці служби у своїй системі:

- Служба OpenVPN працює в режимі TCP.
- Одна або декілька веб-служб http.

Особисто я запускаю кожну веб-службу як контейнери докерів (докерів компонування) і прив’язую їхні http-порти до якогось вільного порту на локальному хості (наприклад, кілька веб-програм працюють на локальному інтерфейсі, але різні порти `http://localhost:20001`, ` http://localhost:20002` тощо).

### Встановіть HAProxy

Спочатку встановіть HAProxy у вашу систему:

{{< highlight shell "linenos=false" >}}
sudo apt install haproxy
{{< / highlight >}}

Потім увімкніть і запустіть systemd демон HAProxy:

{{< highlight shell "linenos=false" >}}
sudo systemctl enable --now haproxy.service
{{< / highlight >}}

### Налаштуйте HAProxy

Розмістіть свої сертифікати SSL у `/etc/ssl/haproxy`. Каталог і сертифікати мають бути доступні лише для користувача root. Наприклад, якщо у вас є домени `domain1.com`, `domain2.com`, для яких ви хочете розмістити веб-сервіси, ви повинні мати сертифікат і пари ключів для кожного домену в каталозі з відповідним іменуванням, наприклад:

- domain1.com.pem
- domain1.com.pem.key
- domain2.com.pem
- domain2.com.pem.key

Потім відредагуйте файл `/etc/haproxy/haporxy.cfg` і додайте необхідні розділи.

### Визначте backend для веб-програм і OpenVPN.

Наприклад, якщо є 2 веб-сайти, які слухають порти 20001, 20002, а OpenVPN – порт 1194, конфігурація буде такою:

```
backend openvpn
    mode tcp
    timeout connect 30s
    timeout server 30s
    retries 3
    server vpn 127.0.0.1:1194

backend app1
    mode http
    server node01 127.0.0.1:20001

backend app2
    mode http
    server node01 127.0.0.1:20002
```

### Налаштуйте балансування HTTPS

Далі нам потрібно створити інтерфейс, який буде прив’язаний до `localhost:8443` і керуватиме перенаправленням на основі домену. Це дозволить розміщувати веб-програми для кількох доменів. Також слід створити бекенд для `localhost:8443`, він буде використовуватися пізніше для підключення з інтерфейсу порту, який буде прослуховуватися на вхідному порту 443.

У цьому прикладі підключення перенаправляється до відповідної веб-програми на основі перевірки SNI домену, наприклад:

```
frontend https
    bind 127.0.0.1:8443 ssl crt /etc/ssl/haproxy/
    http-request redirect scheme https unless { ssl_fc }
    http-request set-header X-Forwarded-Proto https
    http-response set-header Strict-Transport-Security "max-age=16000000; includeSubDomains; preload;"
    use_backend app1 if { ssl_fc_sni domain1.com }
    use_backend app2 if { ssl_fc_sni domain2.com }

backend tcp_to_https
    mode tcp
    server https 127.0.0.1:8443
```

### Налаштуйте frontend для публічного порту 443

Це основний frontend, який прослуховується на загальнодоступному порту 443 і керує перенаправленням на необхідний сервер на основі SNI.

Спочатку він перевіряє, чи SNI закінчується деякими з математичних доменів (domain1.com або domain2.com). Цей вид перевірки дозволяє розмістити будь-який субдомен у майбутньому (наприклад, `dev.domain1.com`, `prod.domain2.com` тощо). І врешті-решт, якщо перевірка SNI не пройдена, це означає, що підключення має бути до OpenVPN, це правило визначено як стандартне.

```
frontend tls
    bind *:443
    mode tcp
    option tcplog
    tcp-request inspect-delay 5s
    tcp-request content accept if { req_ssl_hello_type 1 } or !{ req_ssl_hello_type 1 }
    use_backend tcp_to_https if { req_ssl_sni -m end .domain1.com }
    use_backend tcp_to_https if { req_ssl_sni -m end .domain2.com }
    default_backend openvpn
```

### Приклад повної конфігурації

```
global
    log /dev/log	local0
    log /dev/log	local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

    # Default SSL material locations
    ca-base /etc/ssl/certs
    crt-base /etc/ssl/private

    # See: https://ssl-config.mozilla.org/#server=haproxy&server-version=2.0.3&config=intermediate
    ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
    ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
    ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets

defaults
    log	global
    mode http
    option httplog
    option dontlognull
    timeout connect 5000
    timeout client  50000
    timeout server  50000
    errorfile 400 /etc/haproxy/errors/400.http
    errorfile 403 /etc/haproxy/errors/403.http
    errorfile 408 /etc/haproxy/errors/408.http
    errorfile 500 /etc/haproxy/errors/500.http
    errorfile 502 /etc/haproxy/errors/502.http
    errorfile 503 /etc/haproxy/errors/503.http
    errorfile 504 /etc/haproxy/errors/504.http

frontend tls
    bind *:443
    mode tcp
    option tcplog
    tcp-request inspect-delay 5s
    tcp-request content accept if { req_ssl_hello_type 1 } or !{ req_ssl_hello_type 1 }
    use_backend tcp_to_https if { req_ssl_sni -m end .domain1.com }
    use_backend tcp_to_https if { req_ssl_sni -m end .domain2.com }
    default_backend openvpn

frontend https
    bind 127.0.0.1:8443 ssl crt /etc/ssl/haproxy/
    http-request redirect scheme https unless { ssl_fc }
    http-request set-header X-Forwarded-Proto https
    http-response set-header Strict-Transport-Security "max-age=16000000; includeSubDomains; preload;"
    use_backend app1 if { ssl_fc_sni domain1.com }
    use_backend app2 if { ssl_fc_sni domain2.com }

backend tcp_to_https
    mode tcp
    server https 127.0.0.1:8443

backend openvpn
    mode tcp
    timeout connect 30s
    timeout server 30s
    retries 3
    server vpn 127.0.0.1:1194

backend app1
    mode http
    server node01 127.0.0.1:20001

backend app2
    mode http
    server node01 127.0.0.1:20002
```

## Додатково

### Як перевірити конфігурацію HAProxy

HAProxy може перевірити файл конфігурації та повідомити вам, якщо є якась помилка.

Щоб перевірити конфігурацію, запустіть:

{{< highlight shell "linenos=false" >}}
sudo haporxy -c -f /etc/haproxy/haproxy.cfg
{{< / highlight >}}

### Як застосувати зміни HAProxy

Щоб застосувати зміни до конфігурації HAProxy, просто перезапустіть демон:

{{< highlight shell "linenos=false" >}}
sudo systemctl restart --now haproxy.service
{{< / highlight >}}

## Висновок

Використання HAProxy для обробки завершення SSL і мультиплексування трафіку через порт 443 може бути ефективним способом приховати використання VPN і обійти мережеві обмеження. Це налаштування може бути особливо корисним у середовищах, де відкритий лише порт 443 або трафік VPN активно відстежується та обмежений. Ретельно налаштувавши HAProxy, ви можете створити гнучке та безпечне рішення, яке відповідає вашим потребам.

### Переваги

1. **Мультиплексування портів:** використання порту 443 як для VPN, так і для веб-трафіку дозволяє обійти мережеві обмеження, які дозволяють лише порт 443.

2. **Приховування використання VPN:** завдяки обслуговуванню OpenVPN на порту 443 трафік VPN змішується зі звичайним трафіком HTTPS, що ускладнює його виявлення та блокування.

3. **Гнучкість:** ви можете працювати з кількома службами на одній IP-адресі та порту, зменшуючи кількість відкритих портів і спрощуючи правила брандмауера.

### Що треба мати на увазі

1. **Виявлення:** хоча цей метод може допомогти обійти деякі обмеження, складні інструменти моніторингу мережі все ще можуть потенційно виявляти трафік OpenVPN на основі шаблонів трафіку та поведінки, навіть на порту 443.

2. **Продуктивність:** HAProxy має розшифровувати та перевіряти трафік SSL, що може збільшити витрати. Переконайтеся, що ваш сервер має достатньо ресурсів для обробки додаткового навантаження.

3. **Безпека:** завершення SSL на HAProxy означає, що він виконує шифрування та дешифрування. Переконайтеся, що HAProxy і сервер, на якому він працює, захищені й оновлюються.
