+++
title = "Виготовлення пристрою PiKVM v2 для віддаленого керування комп’ютером або сервером (KVM через IP)"
date = "2024-03-29"
tags = [
    "Саморобні прилади",
    "KVM",
    "KVM через IP",
    "PiKVM",
    "Raspberry PI",
    "GPIO",
    "HDMI",
    "USB",
    "VNC",
    "VPN",
    "Tailscale",
]
categories = [
    "Саморобні прилади",
    "Обладнання",
]
image = "header.jpg"
+++

## Ознайомлення з KVM через IP

KVM через IP (клавіатура, відео, миша через IP) — це технологія, яка забезпечує віддалений доступ і керування комп’ютером або сервером через мережеве з’єднання. Це дозволяє користувачам керувати сервером або ПК так, ніби вони фізично присутні біля машини, незалежно від їхнього розташування. 

### Принцип роботи

- **Апаратний пристрій**: KVM через IP являя собою апаратний пристрій, встановлений на сервері або інтегрований у апаратне забезпечення сервера. Цей пристрій підключається до портів клавіатури, відео та миші сервера.

- **Мережеве підключення**: потім пристрій KVM через IP підключається до мережі інтернет, що забезпечує віддалений доступ до сервера.

- **Програмне забезпечення для доступу**: користувачі можуть отримати віддалений доступ до консолі сервера за допомогою спеціального програмного забезпечення, наданого виробником пристрою KVM через IP. Це програмне забезпечення дозволяє користувачам переглядати екран сервера, керувати введенням даних з клавіатури та миші та взаємодіяти з сервером так, ніби вони фізично присутні.

- **Функції безпеки**: рішення KVM через IP часто мають такі функції безпеки, як шифрування та автентифікація, щоб забезпечити безпечний віддалений доступ до сервера.

### Переваги KVM над програмним забезпеченням віддаленого робочого столу

- **Доступ низького рівня**: KVM через IP забезпечує доступ низького рівня до сервера, дозволяючи користувачам взаємодіяти з сервером або ПК на рівні BIOS та під час процесу завантаження. Цей рівень доступу зазвичай недоступний для програмних рішень для віддаленого робочого столу, які працюють у середовищі операційної системи.

- **Незалежність від операційної системи**: оскільки KVM через IP працює на апаратному рівні, такі апаратні засоби не залежить від операційної системи сервера. Це означає, що його можна використовувати для усунення несправностей і керування серверами та ПК, навіть якщо операційна система не відповідає або не працює.

- **Управління поза діапазоном**: KVM через IP забезпечує можливості керування поза діапазоном, дозволяючи адміністраторам отримувати віддалений доступ і керувати серверами, навіть якщо мережа або операційна система не працює. Це може бути вирішальним для завдань з усунення несправностей і обслуговування.

- **Продуктивність**: рішення KVM через IP часто забезпечують кращу продуктивність порівняно з програмними рішеннями для віддаленого робочого столу, особливо для завдань, які вимагають низької затримки та високої роздільної здатності.

- **Встановлення програмного забезпечення не вимагається**: оскільки KVM через IP є апаратним рішенням, воно не потребує встановлення програмного забезпечення на стороні сервера, що може спростити розгортання та обслуговування.

## Огляд апаратних рішень

### Промислові перемикачі KVM

На ринку доступно багато пристроїв KMV через IP, але вони мають деякі недоліки, якщо вам потрібне доступне рішення для особистого використання, яке включає такі ключові моменти:

- **Вартість**: промислові апаратні рішення KVM зазвичай передбачають вищі витрати порівняно з рішеннями з відкритим кодом, оскільки вони часто мають додаткові функції та послуги підтримки. 

- **Пропрієтарне програмне забезпечення**: більшість KVM-перемикачів, які виготовляються для виробничого використання в серверних кімнатах і центрах обробки даних критичної інфраструктури, постачаються в комплекті з програмним забезпеченням із закритим вихідним кодом, яке має власну ліцензію.

### PiKVM

Найкращим рішенням для персональної домашньої серверної лабораторії або віддаленого керування ПК чи ноутбуком є [PiKVM](https://pikvm.org/) – недороге рішення IP-KVM з відкритим вихідним кодом на основі одноплатного ARM комп’ютера [Raspberry Pi](https://www.raspberrypi.com/products/) .

Пристрій [PiKVM](https://pikvm.org/) має багато корисних функцій для керування віддаленою машиною, наприклад:

- Симуляція дисків: це дозволяє прикріпити локальний файл *.iso до віддаленої машини, це дозволяє віддалено переінсталювати будь-яку ОС.

- Імітація підключення/відключення USB периферії.

- Контроль живленням ATX.

Якщо ви хочете стати власником пристрою [PiKVM](https://pikvm.org/), то для вас існує 2 варіанти:

- Замовити готовий пристрій на офіційному сайті.

- Придбайте одну з [підтримуваних](https://docs.pikvm.org/v2/) плат Raspberry Pi, а також необхідні електронні компоненти та зберіть пристрій своїми руками.

## Створення власного пристрою PiKVM v2

Я вирішив самостійно створити пристрій PiKVM v2, оскільки для моєї країни немає варіантів доставки готових пристроїв. Крім того, збірка своїми руками дає більше гнучкості: можена створити пристрій відповідно до необхідних функцій, при цьоми обирати будь-які компоненти за власним бажанням.

### Вибір компонентів

Після вивчення офіційної документації PiKVM стає очевидним, що найкращою версією для збірки є PiKVM v2. Для виготовлення свого пристрою я використовував такі апаратні компоненти:

- 1 x [Raspberry Pi 4 Model B](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/) з 2 Гб оперативної пам'яті.
- 1 x [Блок живлення GAN 65W PD](https://prom.ua/ua/p2056074929-blok-zhivlennya-gan.html?product_id=2056074929&category_ids=71109)
- 1 x [HDMI USB карта захоплення відео](https://www.aliexpress.com/item/1005001880861192.html?spm=a2g0o.order_list.order_list_main.11.6b4f1802HEgPtC)
- 1 x Kingston SD картка пам'яті на 32 Gb 10-го класу.
- 2 x USB-A до USB-C кабелі (для виготовлення спеціального кабелю живлення).
- 1 X HDMI кабель.
- 1 x 80мм вентилятор (для активного охолодження).

![Комплектуючі необхідні для PiKVM.](img/IMG_20240330_172625_917.jpg)

### Виготовлення спеціального кабелю живлення

Щоб мати можливість керувати віддаленим комп’ютером через саморобний KVM пристрій, комп’ютер повинен розпізнавати наш пристрій як HID USB-пристрій, який сприйматиметься комп’ютером так само, як нібито це інша клавіатура чи миша (комп’ютерна клавіатура та миша також є HID-пристроями).

Але плата Raspberry Pi 4 Model B має критичний недлоік – вона має лише один порт USB-C, який може працювати як пристрій HID, і цей порт також використовується для живлення пристрою. Щоб виправити таке функціональне обмеження, треба виготовити спеціальний кабель, що може одночасно працювати як USB-пристрій для цільового хоста та отримувати зовнішнє живлення від адаптера живлення.

Щоб виготовити такий нестандартний кабель живлення, вам знадобляться 2 кабелі **USB-A male до USB-C male**. Я рекомендую вибирати якісні кабелі, тому що для живлення плати сила струму становить 3А. Процес виготовлення кабелю включає наступні етапи:

1. Візьміть перший кабель і зріжте ізоляцію. Залиште дроти лінії передачі даних (зелений і білий) як є та відріжте дроти живлення +5В (червоний) і землю (чорний).

2. Візьміть другий кабель і відріжте його повністю. Нам потрібна лише частина USB-A.

3. Припаяйте провід живлення +5В (червоний) другої частини кабелю USB-A, до проводу живлення +5В (червоний) частини кабелю USB-C.

4. Припаяйте разом усі 3 заземлюючі (чорні) дроти всіх частин кабелю.

5. Ретельно ізолюйте всі контакти.

Таким чином, роз’єм USB-C слід під’єднати до плати Raspberry Pi, роз’єм USB-A другого кабелю (того, до якого підключено живлення) слід під’єднати до адаптера живлення, а роз’єм USB-A першого кабелю (того, з дроти даних) слід підключити до ПК, яким ви хочете керувати. Для кращого розуміння нижче наведена схема пайки кабелю.

![Схема підключення роз'ємів спеціального кабелю живлення PiKVM v2.](v2_splitter_soldering.png)

Також я рекомендую це відео на YouTube від розробника PiKVM, яке пояснює повний процес виготовлення цього спеціального кабелю.

{{< youtube id="uLuBuQUF61o" >}}

<!-- https://www.youtube.com/watch?v=uLuBuQUF61o -->

Ось фото кабелю, що вийшов у мене. Я позначив усі сторони кабелю, щоб уникнути плутанини роз'ємів під час підключення обладнання. Чорний кабель USB-A повинен підключатися до адаптера живлення, білий кабель USB-A — до комп’ютера, а роз’єм USB-C — для плати Raspberry Pi.

![Фінальний вигляд кастомного кабелю живлення.](img/IMG_11.jpg)

### Збірка пристрою в саморобному корпусі

Компоненти, які я використовую для створення пристрою, включають зовнішню плату захоплення відеосигналу HDMI, яку слід підключити до конкретного USB-порту плати Raspberry Pi. Для моїх потреб пристрій має бути портативним. Враховуючи це, офіційний корпус для Raspberry Pi дуже підходить, до того ж він коштує занадто дорого, на мій погляд. Тож я вирішив повністю зібрати пристрій та всі електронні компоненти в одному корпусі для кращої портативності. Кожен раз, коли мені потрібно використовувати його з іншим ПК, мені просто потрібно підключити до нього кабелі HDMI та USB.

Також не секрет, що плати Rasperry Pi можуть перегріватися під час роботи в умовах екстремального навантаження на процесор або в умовах безперервної роботи 24/7. Беручи це до уваги, я вирішив сконструювати корпус таким чином, щоб усе обладнання охолоджувалося вентилятором 80мм.

На жаль, у мене немає 3D-принтера, щоб спроектувати та створити якісний корпус, що мав би вигляд як у промислового пристрою. Мій корпус повністю ручної роботи. Я використовував переважно деякі старі пластикові панелі, що залишилися в мене після ремонту.

![PiKVM v2 пристрій зібраний в саморобному корпусі з пластикових панелей.](img/IMG_15.jpg)

![Внутрішнє оснащення та розташування електронних компонентів саморобного пристрою PiKVM v2.](img/IMG_12.jpg)

Вентилятор можна підключити до відповідних контактів GPIO на платі. Для цього я використав контакт №2 для +5В (червоний дріт) і контакт №6 для мінусу (чорний дріт) живлення вентилятора.

![Схема GPIO розпіновки плати Raspberry Pi 4 Model B.](GPIO-Pinout-Diagram-2.png)

Я використовував роз’єм що вже був у вентилятора, але мені довелося перепінувати контакти на цьому роз’ємі в правильному порядку.

![Підключення вентилятора до плати Raspberry Pi використовуючи GPIO інтерфейс.](img/IMG_13.jpg)

Також я вирішив додатково винести порт RJ-45 Ethernet збоку, тому що при використання кабельного підключення до мережі інтернет якість потокового відео краща, а затримка менша на відміну від підключення черех Wi-Fi. Для цього я зробив спеціальний подовжувач кабелю та встановив порт біля порту HDMI.

![Порти Ethernet RJ-45 та вхід HDMI змонтовані збоку пристрою.](img/IMG_14.jpg)

### Прошивка PiKVM OS

Для того, щоб Raspberry Pi міг діяти як апаратний KVM-пристрій, слід записати на SD-карту образ операційної системи з відкритим вихідним кодом  PiKVM.

Правильний образ PiKVM, який підходить для конкретної моделі Raspberry Pi, можна знайти на сторінці [PiKVM Flashing OS](https://docs.pikvm.org/flashing_os/). У моєму випадку я завантажив образ платформи DIY PiKVM V2, Raspberry Pi 4 що запрограмовано для використання з HDMI-USB картою захоплення. Образ повністю відповідає апаратному забезпеченню, яке я використовував (Raspblerry Pi 4 Model B і USB карта захоплення відео).

Щоб записани образ ОС на SD-карту, існує програмне забезпечення [RPI Imager](https://github.com/raspberrypi/rpi-imager). Оскільки я використовую Arch Linux, я встановив його з офіційного пакета [rpi-imager](https://archlinux.org/packages/extra/x86_64/rpi-imager/):

{{< highlight shell "linenos=false" >}}
sudo pacman -S rpi-imager
{{< / highlight >}}

Потім слід підключити SD-карту до комп’ютера. Оскільки мій комп’ютер не має вбудованого кард-рідера, я використовую адаптер micro-SD до USB-A.

![Адаптер Micro-SD до USB-A.](img/IMG_10.jpg)

Щоб записати образ на картку пам'яті, виконайте такі дії:

1. Відкрийте RPI Imager.

![Програмне забезпечення RPI Imager.](rpi-img0.png)

2. Натисніть "Choose device" та виберіть модель вашої плати Raspberry Pi. В моєму випадку слід обрати "Raspberry Pi 4".

![Вибір моделі плати.](rpi-img1.png)

3. Натисніть "Choose OS", прокрутіть до самого низу та виберіть опцію "Use custom image". Потім у файловому менеджері виберіть завантажений раніше образ PiKVM.

![Вибір кастомного образу.](rpi-img2.png)

![Вибір файла образу.](rpi-img3.png)

4. Натисніть "Choose storage" та виберіть картку пам'яті. Будьте обережні, та обирайте правильний пристрій, тому що RPI Imager відформатує вибраний пристрій.

![Вибір дискового пристрою.](rpi-img4.png)

5. Переконайтеся, що всі поля заповнено правильно та натисніть «Далі».

![Підготовка до запису.](rpi-img5.png)

6. Далі ви побачите модальне діалогове вікно із запитом, чи бажаєте ви налаштувати деякі параметри, натисніть «НІ».

![Діалогове вікно.](rpi-img6.png)

7. Наостанок підтвердьте процес спалаху пристрою та зачекайте, доки RPI Imager завершить спалах і перевірку зображення.

![Підтвердження запису образу.](rpi-img7.png)

### Налаштування підключення до Wi-Fi (необов'язково)

Як я вже зазначав раніше, завжди краще використовувати кабельне інтернет з’єднання Ethernet RJ-45, оскільки воно надійніше та забезпечує кращу продуктивність відеопотоку та меншу затримку. Однак, оскільки я хочу, щоб пристрій був портативним, і я міг взяти його з собою та підключити до іншого комп'ютера, де, можливо, не буде можливості кабельного з’єднання. Для цього я встановлюю облікові дані Wi-Fi мережі точки доступу свого телефону на Android, який я завжди маю при собі, тому, коли плата Raspberry Pi завантажується без підключеного кабелю Ethernet, вона використовуватиме свій вбудований адаптер Wi-Fi і підключитися до мого телефону Android.

Щоб налаштувати Wi-Fi, виконайте такі дії:

1. Підключіть SD-карту до комп'ютера.

2. Ви побачите, що SD-карта має більше одного розділу, вам потрібно змонтувати перший розділ, який називається "PIBOOT".

![Розділи на картці пам'яті.](rpi-wifi0.png)

3. Знайдіть файл `pikvm.txt` в кореневій папці розділу "PIBOOT". Якщо файла не існує - створіть його вручну, якщо файл вже існує, не видаляйте з нього жодних конфігурацій, вам потрібно додати 2 параметри внизу файлу.

4. Додайте 2 параметри в кінець файлу. Замініть облікові дані у прикладі на облікові дані вашої мережі Wi-Fi.

```bash
WIFI_ESSID='my_wifi_network'
WIFI_PASSWD='the_most_secure_password_ever'
```

5. Збережіть файл. Потім безпечно відключіть розділ і вийміть SD-карту. Встановіть SD-карту на плату.

### Перше завантаження

Це важливий крок, оскільки під час першого завантаження PiKVM OS ініціалізує необхідні налаштування та генерує унікальні SSH-ключі та сертифікати безпеки.

Для процедури першого завантаження виконайте такі кроки:

1. Встановіть SD-карту з прошитою ОС PiKVM на плату Raspberry Pi.

2. Підключіть плату Raspbery Pi до роутера за допомогою кабелю Ethernet RJ-45. Якщо у вас немає можливості використовувати Ethernet під час першого завантаження, ви можете налаштувати облікові дані Wi-Fi (як показано в попередньому кроці), але перед завантаженням переконайтеся, що мережа Wi-Fi доступна.

3. Завантажте плату Raspberry Pi. Для цього підключіть джерело живлення 5В 3А до порту USB-C на платі.

![Процедура першого завантаження мого PiKVM пристрою.](img/IMG_9.jpg)

4. Зачекайте деякий час, поки ОС PiKVM завершить першу ініціалізацію. Цей процес може тривати до 10 хвилин.

> 🔴 **ВАЖЛИВО:** не від’єднуйте кабель живлення від плати Raspberry Pi, доки не завершиться перша ініціалізація завантаження.

5. Після завершення процесу першого завантаження пристрій PiKVM підключиться до мережі та отримає локальну IP-адресу в локальній мережі вашого маршрутизатора. Щоб визначити, яку IP-адресу отримав PiKVM, перейдіть на сторінку налаштувань маршрутизатора та знайдіть підключені пристрої.

У моєму випадку плата отримала IP-адресу `192.168.0.222`, тому я буду використовувати її в усіх наступних прикладах. У вашому випадку IP-адреса буде іншою.

![Пристрій PiKVM що підключено до локальної мережі роутера.](router.jpg)

6. Далі вам потрібен комп’ютер або смартфон, який під’єднаний до тієї ж локальної мережі, що й пристрій PiKVM. Відкрийте веб-браузер і перейдіть до URL-адреси IP-адреси `https://192.168.0.222`. Облікові дані за замовчуванням: логін `admin` з паролем `admin`.

7. Змініть стандартні паролі, щоб захистити свій пристрій. Детальний опис того, як це зробити, є в [докуменації PiKVM](https://docs.pikvm.org/v2/#first-launch-and-usage).

![Процедура зміни стандартних паролів.](pw_change.png)

### Оновлення програмного забезпечення PiKVM OS

PiKVM OS — це операційна система з відкритим кодом на базі Arch Linux. Важливо регулярно оновлювати ОС PiKVM, щоб отримувати оновлення безпеки та нові функції. Як і оновлення будь якої системи, основаної на базі ядра Linux, процедура також виконується через термінал. Ви можете використовувати оболонку ssh або термінал вбудований в веб-інтерфейс PiKVM.

Щоб оновити ОС, виконайте такі дії:

1. Відкрийте термінал у веб-інтерфейсі PiKVM. В якості альтернативи можна використовувати ssh.

2. Отримайте root-доступ, ввівши команду `su -` і пароль від користувачва root.

3. Виконайте команду `pikvm-update` і дочекайтеся завершення процесу. Будь ласка, переконайтеся, що ваш пристрій PiKVM не буде від'єднано від живлення та підключення до мережі інтернет під час процесу оновлення.

### Налаштування Tailscale VPN (необов’язково)

Можуть виникнути ситуації, коли я не можу отримати доступ до однієї локальної мережі з платою PiKVM, наприклад, коли я підключив PiKVM до домашнього сервера, і я фізично не вдома, і мені потрібен віддалений доступ до мого сервера.

Крім того, враховуючи критерій щоб PiKVM був максимально портативним, я також хочу мати можливість позичити свій пристрій PiKVM комусь, щоб ця особа могла взяти його та підключити до свого ПК та локальної мережі, а я в свою чергу міг підключитися до цього ПК віддалено, та, наприклад, зміг допогти встановити операційну систему.

[Tailscale VPN](https://tailscale.com/) — це безкоштовний інструмент (для особистого користування), який можна використовувати як рішення для вище описаних випадків. Він дозволяє отримати доступ до PiKVM через мережу інтернет. Щоб налаштувати його, виконайте такі дії:

1. Відкрийте термінал у веб-інтерфейсі PiKVM. В якості альтернативи можна використовувати ssh.

2. Встановіть службу tailscale, ввівши цю послідовність команд в терміналі:

```bash
su -
rw
pacman -S tailscale-pikvm
systemctl enable --now tailscaled
tailscale up
```

3. Термінал покаже посилання, яке потрібно скопіювати та перейти у веб-браузері. Після переходу за посиланням увійдіть або зареєструйтеся в Tailscale VPN, тоді ваш пристрій PiKVM буде долучено до цього облікового запису.

4. Встановіть клієнт Tailscale у систему, яку ви хочете використовувати (не на комп’ютер, яким хочете керувати через PiKVM), і підключіть його до VPN. Для цього дотримуйтесь інструкцій [тут](https://tailscale.com/download).

5. Після налаштування клієнта у вашій системі відвідайте [сторінку адміністратора Tailscale](https://login.tailscale.com/admin/machines). Якщо ви все зробили правильно, ви повинні побачити свій пристрій PiKVM і систему, що використовується для віддаленого підключення до PiKVM.

![Інформаційна панель адміністратора TailScale, на якій показано підключені пристрої.](tailscale_admin1.jpg)

На знімку екрана вище я виділив приклад IP-адреси, яку слід використовувати в браузері для віддаленого підключення до PiKVM.

6. Переконайтеся, що ви вимкнули термін дії ключа для пристрою PiKVM. Щоб зробити це, натисніть значок «три крапки» праворуч від пристрою PiKVM у списку та виберіть опцію «Вимкнути термін дії ключа».

Після завершення налаштування під час кожного завантаження пристрою PiKVM він автоматично підключатиметься до мережі VPN, тому, якщо мені потрібен віддалений доступ до нього з будь-якого місця, я можу просто підключити свій ноутбук чи телефон, що маю з собою, до тієї ж мережі VPN та керувати своїм пристроєм PiKVM.

## Інструкція з використання пристрою PiKVM для керування ПК / ноутбуком / сервером

Це інструкція стосується використання пристрою PiKVM як портативного. Для підключення вам необхідно мати: пристрій **PiKVM**, **машину**, якою ви хочете керувати, спеціальний кабель живлення та адаптер, кабель Ethernet RJ-45, кабель HDMI.

1. Візьміть кабель **Ethernet RJ-45** та підключіть його до пристрою **PiKVM** та до вашого **роутера**.

![Ethernet RJ-45 що підключено до PiKVM.](img/IMG_8.jpg)
![Ethernet RJ-45 що підключено до роутера.](img/IMG_7.jpg)
![Мережеве з'єданння між роутером та PiKVM.](img/IMG_6.jpg)

2. Візьміть кабель **HDMI** та підключіть його до пристрою **PiKVM** та до **машини**, якою ви хочете керувати.

![HDMI кабель що підключено до PiKVM.](img/IMG_5.jpg)
![HDMIабель що підключено до ноутбука (буде розпізнаватися як монітор у системі).](img/IMG_4.jpg)
![HDMI з'єданння між PiKVM ноутбуком.](img/IMG_3.jpg)

3. Візьміть спеціальний кабель живлення та підключіть:
    - **USB-C** роз'єм до пристрою **PiKVM**.
    - **USB-A** роз'єм що позначено _"PC/Laptop (комп'ютер)"_ до **машини**, якою ви хочете керувати.
    - **USB-A** роз'єм що позначено _"Power (живлення)"_ до **адаптера живлення**.

![Підключення USB-C роз'єму до PiKVM пристрою.](img/IMG_2.jpg)
![Підключення USB-A роз'єму для передачі даних до ноутбука (буде розпізнаватися як миша/клавіатура в системі.).](img/IMG_1.jpg)
![Підключення USB-A роз'єму до адаптера живлення 5V 3A.](img/IMG.jpg)

4. Підключіть **адаптер живлення** до електричної розетки. Пристрій **PiKVM** має завантажитися та підключитися до мережі.

5. Запустіть **машину**, якою ви хочете керувати.

Після цього ви зможете підключитися до пристрою **PiKVM**.

![Приклад KVM сесії віддаленого керування ноутбуком через веб-інтерфейс PiKVM.](pikvm-web.png)

## Висновки

В результаті цього проекту було зібрано портативний пристрій KVM через IP, який має весь необхідний для моїх потреб функціонал:

- Пристрій може використовувати як Ethernet, так і Wi-Fi з'єднання.
- Пристроєм можна повністю керувати віддалено за допомогою VPN.
- Пристрій зібрано в спеціальному унікальному корпусі ручної роботи, що використовує активне охолодження для запобігання перегріванню пристрою, тому його можна безпечно використовувати 24/7.