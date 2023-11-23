+++
title = "How to make systemd-boot remember the last selected entry"
date = "2023-11-22"
tags = [
    "Linux",
    "Bootloader",
    "systemd-boot",
]
categories = [
    "Linux",
]
image = "header.png"
+++

## Introduction

When using systemd-boot as your bootloader, you may find it convenient to have the system remember the last selected entry on each subsequent boot. This is especially useful for users who frequently switch between different operating systems or kernels. By configuring systemd-boot to remember the last chosen boot entry, you can streamline the boot process and avoid having to manually select the desired option every time the system restarts.

## Modifying the Configuration File

To achieve this functionality, you need to modify the loader.conf configuration file. The exact location of this file can vary depending on the Linux distribution you are using. 

Personally, I have used several Linux distributions, and the path for `loader.conf` was different in each of them, for example:

- For **Ubuntu** it was `/boot/efi/loader/loader.conf`
- For **Arch Linux** it was `/boot/loader/loader.conf`
- For **EndeavourOS** it was `/efi/loader/loader.conf`

To modify the file open the Terminal and follow this steps:

1. Open the `loader.conf` file for editing, for example:

{{< highlight shell "linenos=false" >}}
sudo nano /boot/loader/loader.conf
{{< / highlight >}}

2. Modify the `default` parameter like below:

{{< highlight shell "linenos=false" >}}
default @saved
{{< / highlight >}}

3. Save the file (In nano, this is done with the keyboard shortcut `Ctrl + O'). 

At the next boot, after you will select some entry it will be remembered as the default.

## Conclusions

By configuring systemd-boot to remember the last selected entry, you can streamline your boot process and enhance the overall user experience. Whether you're using Arch Linux, Ubuntu, or another distribution that employs systemd-boot, this simple modification can save you time and make your system startup more efficient.

Remember to adapt the file paths and commands based on the specifics of your distribution. With this configuration in place, your system will automatically boot into the last chosen entry, reducing the need for manual intervention during the boot process.
