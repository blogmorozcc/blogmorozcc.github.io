+++
title = "Assembling a PiKVM v2 device for remote KVM over IP control of a computer or server"
date = "2024-03-29"
tags = [
    "KVM",
    "KVM over IP",
    "PiKVM",
    "Raspberry PI",
    "HDMI",
    "USB",
    "VNC",
]
categories = [
    "DIY",
    "Hardware",
]
image = "header.webp"
+++

## Introduction to KVM over IP

KVM over IP (Keyboard, Video, Mouse over IP) is a technology that allows remote access and control of a computer or server through a network connection. It enables users to manage the server's or PC's console as if they were physically present at the machine, regardless of their location. Here's how it works and its advantages over software remote desktop solutions:

### How it works

- **Hardware Device**: KVM over IP typically involves a hardware device installed on the server or integrated into the server's hardware. This device connects to the server's keyboard, video, and mouse ports.

- **Network Connection**: The KVM over IP device is then connected to the network, allowing remote access to the server.

- **Access Software**: Users can access the server's console remotely using specialized software provided by the KVM over IP device manufacturer. This software allows users to view the server's screen, control the keyboard and mouse input, and interact with the server as if they were physically present.

- **Security Features**: KVM over IP solutions often come with security features such as encryption and authentication to ensure secure remote access to the server.

### Advantages over software remote desktop

- **Low-Level Access**: KVM over IP provides low-level access to the server's console, allowing users to interact with the server or PC at the BIOS level and during the boot process. This level of access is not typically available with software remote desktop solutions, which operate within the operating system environment.

- **Operating System Independence**: Since KVM over IP operates at a hardware level, it is independent of the server's operating system. This means it can be used to troubleshoot and manage servers even if the operating system is unresponsive or malfunctioning.

- **Out-of-Band Management**: KVM over IP provides out-of-band management capabilities, allowing administrators to remotely access and manage servers even if the network or operating system is down. This can be crucial for troubleshooting and maintenance tasks.

- **Performance**: KVM over IP solutions often offer better performance compared to software remote desktop solutions, especially for tasks that require low-latency and high-resolution video output.

- **No Software Installation Required**: Since KVM over IP is a hardware-based solution, it does not require any software installation on the server side, which can simplify deployment and maintenance.

## Hardware solutions overview

### Commercial KVM switches

There are plenty of KMV over IP devices available on the market, but they have some disatvantages in case you need some sort of solution for personal use, which includes this key points:

- **Cost**: Commercial hardware KVM solutions typically involve higher upfront costs compared to open-source solutions, as they often come with additional features and support services. Open-source solutions like LibreEMS and IPMI are more cost-effective in terms of hardware expenses.

- **Non-free software**: Most of the KVM switches that are manufactured for production use in server rooms and critical infrastructure datacenters are bundled with closed source software that has proprietary license.

### PiKVM

The best solution for the personal home-lab server room or remote management of the PC is [PiKVM](https://pikvm.org/) - and open and inexpensive IP-KVM solution based on [Raspberry Pi](https://www.raspberrypi.com/products/) single board ARM computer.

The [PiKVM](https://pikvm.org/) device has many useful features to control remote machine, for example:

- Storage simulation: this allows you to attach local *.iso file to the remote machine, it allows you to reinstall any OS remotely.

- USB removal/insertion simulation.

- ATX power control.

If you want to have a [PiKVM](https://pikvm.org/) device for yourself there are 2 options:

- Order a pre-built device on the official website.

- Buy one of the Raspberry Pi boards that are [supported](https://docs.pikvm.org/v2/) as well as some components and assemble the DIY device. 

## Building own PiKVM v2 device

I decided to build PiKVM v2 device myself, as there are no delivery of pre-built devices available for my country. Also DIY build gives more flexibility: you can build device according to needed features, you can choose whatever components you want.

### Choosing components

After investigating the PiKVM official documentation it's obvious that the best version to build is PiKVM v2. To assemble the device I used this list of hardware components:

- 1 x [Raspberry Pi 4 Model B](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/) with 2 Gb of RAM.
- 1 x [Power adapter GAN 65W PD](https://prom.ua/ua/p2056074929-blok-zhivlennya-gan.html?token=v2%3AFhRGDfXrgW-JeeoVxg4uJB3qmxltBSE89kSZYPuKxJGqL49CUkKuRZgMYkJJl50TnXWK_qvyZRVxL1syJB87F-e4NWzotHV185XO4MTe0i6RhA_4zvZ-bBXOukyL0_KO&campaign_id=3563069&product_id=2056074929&source=prom%3Acompany%3Apage&locale=uk&category_ids=71109&from_spa=true)
- 1 x [HDMI USB video capture card](https://www.aliexpress.com/item/1005001880861192.html?spm=a2g0o.order_list.order_list_main.11.6b4f1802HEgPtC)
- 1 x Kingston SD Card 32 Gb 10 class.
- 2 x USB-A to USB-C cables (to build cusom power cable).
- 1 X HDMI male-male cable.
- 1 x 80mm FAN (for active cooling).

### Building cusom power cable

To be able to operate the remote machinve wiht our DIY KVM device computer should be able to recognize our device as HID USB device that will be treated by the computer just like another keyboard or mouse (the computer keyboard and mouse are also HID device). 

The problem with Raspberry Pi 4 Model B board - it has only one USB-C port that is able to act as a HID device and that port is also used to power the device. To fix this there is workaround that requires tou build a special cable that can simultanously act as USB Device for the target host and receive external power from the power adapter.

To build this custom power cable you need 2 x **USB-A male to USB-C male** cables. I recommend choosing good quality cables because board requires 3 amp current power. The process of building cable includes this steps:

1. Take the first cable and cut the isolation. Leave the data line wires (green and white) as is, and cut the power +5V (red) and ground (black) wires.

2. Take the second cable and cut it completely. You need only the USB-A part of it. 

3. Solder power +5V (red) wire of the second USB-A cable part with the power +5V (red) wire of the USB-C cable part.

4. Solder all of the 3 ground (black) wires of all the cable parts together.

5. Isolate everything with the electric tape. 

So the USB-C connector should be plugged in Raspberry Pi board, USB-A connector of the second cable (the one with power wired) should be plugged in power adapter, and the USB-A connector of the first cable (the one with data wires) should be plugged to the PC you want to control. For better understanding there is a cable soldering scheme below.

![PiKVM v2 custom cable scheme](v2_splitter_soldering.png)

Also I recommend this video on YouTube from the PiKVM developer which explains the full process of making this custom cable.

{{< youtube id="uLuBuQUF61o" >}}

<!-- https://www.youtube.com/watch?v=uLuBuQUF61o -->

### Assenble a custom case

The components I use to build the device include external HDMI video signal capture card that should be connected to the specific USB port of the Raspberry Pi board. For my needs the device should be portable, so there is a risk of using the wrong port if I should connect the card every time. Considering this, the official Raspberry Pi case is not an option, also it costs too much in my opinion. So I decided to assamble the device in a single case for better portability and plug & play experience, every time I need to use it with another PC I simply need connect HDMI and USB cables to it.

Also it's not a secret that Rasperry Pi boards can get overheated when working in extreme CPU load conditions or with 24/7 uptime. Taking that to account, I decided to construct a case in a way that all of the hardware will be cooled with 80mm fan.

Unfortunately, I have no 3D printer to engineer accurate case, so my case is fully hand made. I used mostly some old pieces of plastic panels that I had at the time. 

<!-- ToDo photo -->

The fan can be connected to the appropriate GPIO pins on the board. For that I used pin #2 for +5v (red wire) and pin #6 for ground (black wire) to power the fan.

![Raspberry Pi 4 Model B GPIO Pinout scheme](GPIO-Pinout-Diagram-2.png)

<!-- ToDo photo -->

Also I decided to include the RJ-45 Ethernet port on the side, because the quality of stream is better and the latency is less when using cable internet connection instead of Wi-Fi. For that I made a custom cable extension and mounted the port near the HDMI input.

<!-- ToDo photo -->

### Flashing PiKVM OS

### Configuring Wi-Fi connection

### Setting up Tailscale VPN

## How to use PiKVM device to control PC / Laptop / Server

## Conclusion

