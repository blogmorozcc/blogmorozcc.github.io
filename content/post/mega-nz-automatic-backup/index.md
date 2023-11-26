+++
title = "Automatic server backup to the Mega.nz cloud"
date = "2016-10-02"
tags = [
    "Linux",
    "Cloud",
    "Backup",
]
categories = [
    "Linux",
    "Networking",
]
image = "header.jpg"
+++

## Introduction

Mega.nz is one of the most affordable cloud storage in terms of volume, because it provides its new users with 50Gb of cloud disk space absolutely free. There are also paid plans that allow you to expand the cloud up to 4 terabytes. But even 50Gb is quite enough for backup copies of sites and MySQL databases. Also, there is a set of megatools console utilities for downloading and uploading files to a remote cloud.

## Solution setup

### Installing megatools

First, register and activate your mega.nz account if you don't already have one.

Next, you need to connect to the server via SSH, and install the necessary packages for assembling megatools:

{{< highlight shell "linenos=false" >}}
sudo apt-get -y install build-essential libglib2.0-dev libssl-dev libcurl4-openssl-dev libgirepository1.0-dev
{{< / highlight >}}

After that, you should find a link to download megatools on the official website, which we then use to download with the wget command.

```bash
cd /opt
wget https://megatools.megous.com/builds/megatools-1.9.97.tar.gz
tar -xvzf megatools-1.9.97.tar.gz
```

After we have downloaded and unzipped the source code, we need to compile it. This can be done using the following sequence of commands:

```bash
cd megatools-1.9.97
./configure
make
make install
```

If everything was compiled and installed without errors, you can proceed to the next stage, namely writing a script for creating and uploading backups to the cloud.

### Creating a backup script

First, we create a file with data for logging into the account:

```bash
cd ~
nano .megarc
```

The file should be filled as follows:

```bash
[Login]
Username = {Your login}
Password = {Your password}
```

As our login data is stored unencrypted, let's make it available only to root.

{{< highlight shell "linenos=false" >}}
chmod 640 .megarc
{{< / highlight >}}

Now let's check the correctness of entering the login and password, for this we enter the command:

{{< highlight shell "linenos=false" >}}
megals
{{< / highlight >}}

If all settings are correct, it should display a list of files. If the command did not display a list of files, then we check the correctness of entering the password, if it did, then we proceed to the next step of creating a backup script. In this case, the scripts are stored in the /opt/scripts directory with modified permissions.

{{< highlight shell "linenos=false" >}}
nano /opt/scripts/do_backup.sh
{{< / highlight >}}

The script looks like this:

```bash
#!/bin/bash
SERVER="server"
DAYS_TO_BACKUP=7
WORKING_DIR="/root/tmp_dir"
BACKUP_MYSQL="true"
MYSQL_USER="{Your MySQL user}"
MYSQL_PASSWORD="{Your MySQL password}"
DOMAINS_FOLDER="/var/www"
##################################
# We create a temporary folder for creating archives
rm -rf ${WORKING_DIR}
mkdir ${WORKING_DIR}
cd ${WORKING_DIR}
# Archive /etc
cd /
tar cJf ${WORKING_DIR}/etc.tar.gx etc
cd - > /dev/null
# Backup MySQL
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
# Backup websites
mkdir ${WORKING_DIR}/domains
for folder in $(find ${DOMAINS_FOLDER} -mindepth 1 -maxdepth 1 -type d)
do
 cd $(dirname ${folder})
 tar cJf ${WORKING_DIR}/domains/$(basename ${folder}).tar.xz $(basename ${folder})
 cd - > /dev/null
done
##################################
# Handling possible dbus-errors
export $(dbus-launch)
# Create a folder on the cloud with the name of the server, and in it another folder with today's date
[ -z "$(megals --reload /Root/backup_${SERVER})" ] && megamkdir /Root/backup_${SERVER}
# Cleaning old unnecessary logs
while [ $(megals --reload /Root/backup_${SERVER} | grep -E "/Root/backup_${SERVER}/[0-9]{4}-[0-9]{2}-[0-9]{2}$" | wc -l) -gt ${DAYS_TO_BACKUP} ]
do
 TO_REMOVE=$(megals --reload /Root/backup_${SERVER} | grep -E "/Root/backup_${SERVER}/[0-9]{4}-[0-9]{2}-[0-9]{2}$" | sort | head -n 1)
 megarm ${TO_REMOVE}
done
# Create a folder for backup
curday=$(date +%F)
megamkdir /Root/backup_${SERVER}/${curday} 2> /dev/null
# Upload the files to cloud
megacopy --reload --no-progress --local ${WORKING_DIR} --remote /Root/backup_${SERVER}/${curday} > /dev/null
# Kill DBUS-daemon
kill ${DBUS_SESSION_BUS_PID}
rm -f ${DBUS_SESSION_BUS_ADDRESS}
# Remove temporary files
rm -rf ${WORKING_DIR}
exit 0
```

Now you need to allow the execution of the script:

{{< highlight shell "linenos=false" >}}
chmod a+x /opt/scripts/do_backup.sh
{{< / highlight >}}

Next, you need to test the script by directly executing it:

{{< highlight shell "linenos=false" >}}
/opt/scripts/do_backup.sh
{{< / highlight >}}

After that, you can go to the mega account through the web interface and check that the necessary files have appeared there.

### Creating a script autorun rule in crontab

In order for the script to run according to a certain time schedule, let's add it to the crontab.

{{< highlight shell "linenos=false" >}}
04 04 * * * root /opt/scripts/do_backup.sh
{{< / highlight >}}

## Is it optimal to use ?

In my case, the backup folder is `538.8 Mb` in size.

A total of `50,000 Mb` of free space on the cloud. Let each backup weigh approximately `550 Mb`. We divide 50,000 by 550, we have:

{{< highlight shell "linenos=false" >}}
50000 / 550 ≈ 90.9
{{< / highlight >}}

This means that the cloud is enough for 90 backups, which is quite a large number, especially if you take into account the free service of Mega.

But optimality as a whole depends on factors:
- Backup size
- Backup frequency
- Storage duration of each backup

Therefore, it is advisable to evaluate the optimality separately for each individual case.
