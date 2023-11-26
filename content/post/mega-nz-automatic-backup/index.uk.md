+++
title = "Автоматичние резервне копіювання сервера в хмарне середовище Mega.nz"
date = "2016-10-02"
tags = [
    "Linux",
    "Cloud",
    "Backup",
]
categories = [
    "Linux",
    "Мережі",
]
image = "header.jpg"
+++

## Введення

Mega.nz одне з найдоступніших хмарних сховищ за об'ємом, адже надає своїм новим користувачам 50Gb хмарного дискового простору абсолютно безкоштовно. Є також платні тарифи, які дозволяють розширити хмару аж до 4 терабайт. Але для резервних копій сайтів та баз даних MySQL цілком вистачає навіть 50Gb. Також, є набір консольних утиліт megatools для скачування та вивантаження файлів на віддалену хмару.

## Налаштування

### Встановлення megatools

Для початку зареєструйте та активуйте собі обліковий запис на сайті mega.nz, якщо у вас його досі немає.

Далі треба підключитися до сервера по SSH, та встановити необхідні для збирання megatools пакети:

{{< highlight shell "linenos=false" >}}
sudo apt-get -y install build-essential libglib2.0-dev libssl-dev libcurl4-openssl-dev libgirepository1.0-dev
{{< / highlight >}}

Після цього на офіційному сайті варто знайти посилання на завантаження megatools, яке потім використовуємо для завантаження командою wget.

```bash
cd /opt
wget https://megatools.megous.com/builds/megatools-1.9.97.tar.gz
tar -xvzf megatools-1.9.97.tar.gz
```

Після того як ми завантажили та розархівували вихідний код, треба його скомпілювати. Це можна зробити за допомогою наступної послідовності команд:

```bash
cd megatools-1.9.97
./configure
make
make install
```

Якщо все скомпілювалося і встановилося без помилок, можна переходити до наступного етапу, а саме написання скрипта для створення і вивантаження бекапів в хмару.

### Створення скрипта для резервного копіювання

Спочатку створюємо файл із даними для входу до облікового запису:

```bash
cd ~
nano .megarc
```

Файл має бути наповнено таким чином:

```bash
[Login]
Username = {Ваш логін}
Password = {Ваш пароль}
```

Так як у нас дані для входу зберігаються у відкритому вигляді, зробимо їх доступними лише для root.

{{< highlight shell "linenos=false" >}}
chmod 640 .megarc
{{< / highlight >}}

Тепер перевіримо правильність введення логіну з паролем, для цього вводимо команду:

{{< highlight shell "linenos=false" >}}
megals
{{< / highlight >}}

Якщо всі налаштування корректні, вона має вивести на екран список файлів. Якщо команда не вивела список файлів, то перевіряємо правильність введення пароля, якщо вивела, то переходимо до наступного кроку створення скрипту для бекапу. В даному випадку скрипти зберігаються в директорії /opt/scripts з модифікованими правами.

{{< highlight shell "linenos=false" >}}
nano /opt/scripts/do_backup.sh
{{< / highlight >}}

Скрипт виглядає так:

```bash
#!/bin/bash
SERVER="server"
DAYS_TO_BACKUP=7
WORKING_DIR="/root/tmp_dir"
BACKUP_MYSQL="true"
MYSQL_USER="{Ваш користувач MySQL}"
MYSQL_PASSWORD="{Ваш пароль користувача MySQL}"
DOMAINS_FOLDER="/var/www"
##################################
# Створюємо тимчасову папку для створення архівів
rm -rf ${WORKING_DIR}
mkdir ${WORKING_DIR}
cd ${WORKING_DIR}
# Архівуємо папку /etc
cd /
tar cJf ${WORKING_DIR}/etc.tar.gx etc
cd - > /dev/null
# Бекап бази даних MySQL
if [ "${BACKUP_MYSQL}" = "true" ]
then
 mkdir ${WORKING_DIR}/mysql
 for db in $(mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e 'show databases;' | grep -Ev "^(Database|mysql|information_schema|performance_schema|phpmyadmin)$")
 do
 #echo "processing ${db}"
 mysqldump --opt -u${MYSQL_USER} -p${MYSQL_PASSWORD} "${db}" | gzip > ${WORKING_DIR}/mysql/${db}_$(date +%F_%T).sql.gz
 done
 #echo "all db now"
 mysqldump --opt -u${MYSQL_USER} -p${MYSQL_PASSWORD} --events --ignore-table=mysql.event --all-databases | gzip > ${WORKING_DIR}/mysql/ALL_DATABASES_$(date +%F_%T).sql.gz
fi
# Бекап сайтів
mkdir ${WORKING_DIR}/domains
for folder in $(find ${DOMAINS_FOLDER} -mindepth 1 -maxdepth 1 -type d)
do
 cd $(dirname ${folder})
 tar cJf ${WORKING_DIR}/domains/$(basename ${folder}).tar.xz $(basename ${folder})
 cd - > /dev/null
done
##################################
# Захищаємось від помилок dbus-error
export $(dbus-launch)
# Створюємо на хмарі папку з ім'ям сервера, а в ній ще одну з сьогоднішньою датою
[ -z "$(megals --reload /Root/backup_${SERVER})" ] && megamkdir /Root/backup_${SERVER}
# Очистка старих непотрібних логів
while [ $(megals --reload /Root/backup_${SERVER} | grep -E "/Root/backup_${SERVER}/[0-9]{4}-[0-9]{2}-[0-9]{2}$" | wc -l) -gt ${DAYS_TO_BACKUP} ]
do
 TO_REMOVE=$(megals --reload /Root/backup_${SERVER} | grep -E "/Root/backup_${SERVER}/[0-9]{4}-[0-9]{2}-[0-9]{2}$" | sort | head -n 1)
 megarm ${TO_REMOVE}
done
# Створюємо папку
curday=$(date +%F)
megamkdir /Root/backup_${SERVER}/${curday} 2> /dev/null
# Завантажуємо файли на віддалену хмару
megacopy --reload --no-progress --local ${WORKING_DIR} --remote /Root/backup_${SERVER}/${curday} > /dev/null
# Вбиваємо DBUS-daemon
kill ${DBUS_SESSION_BUS_PID}
rm -f ${DBUS_SESSION_BUS_ADDRESS}
# Видаляємо тимчасові файли
rm -rf ${WORKING_DIR}
exit 0
```

Тепер потрібно дозволити виконання скрипта:

{{< highlight shell "linenos=false" >}}
chmod a+x /opt/scripts/do_backup.sh
{{< / highlight >}}

Далі необхідно протестувати скрипт, безпосередньо виконавши його:

{{< highlight shell "linenos=false" >}}
/opt/scripts/do_backup.sh
{{< / highlight >}}

Після цього можна зайти на аккаунт mega через веб-інтерфейс, та перевірити що там з'явилися потрібні файли.

### Створення правила автозапуску скрипта в crontab

Тепер щоб скрипт запускався за певним тимчасовим розкладом, додамо його до crontab.

{{< highlight shell "linenos=false" >}}
04 04 * * * root /opt/scripts/do_backup.sh
{{< / highlight >}}

## Оптимальність використання

В моєму випадку папка з бекапом має розмір `538,8 Mb`.

Всього на хмарі `50000 Mb` вільного місця. Нехай у нас кожен бекап приблизно важить `550 Mb`. Ділимо 50000 на 550, маємо:

{{< highlight shell "linenos=false" >}}
50000 / 550 ≈ 90.9
{{< / highlight >}}

Це означає, що хмари вистачить на 90 бекапів, що досить велика цифра, особливо якщо врахувати безкоштовність сервісу Mega. 

Але оптимальність вцілому залежить від чинників:
- Розмір бекапу
- Частота резервного копіювання
- Тривалість зберігання кожного бекапу

Тому для кожного окремого випадку доцільно оцінювати оптимальність окремо.
