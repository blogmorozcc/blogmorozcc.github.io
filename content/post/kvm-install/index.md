+++
title = "How to install KVM on Arch Linux"
date = "2024-03-15"
tags = [
    "Linux",
    "KVM",
    "Virtualization",
]
categories = [
    "Linux",
    "Virtualization",
]
image = "header.png"
+++

## Introduction

KVM, which stands for Kernel-based Virtual Machine, is a virtualization solution for Linux operating systems. It allows you to run multiple virtual machines (VMs) on a single physical machine by leveraging hardware virtualization features built into modern processors.

Here's a breakdown of what KVM offers:

- **Hypervisor**: KVM acts as a hypervisor, which is a piece of software that creates and runs virtual machines. It utilizes the virtualization extensions present in modern processors (such as Intel VT-x or AMD-V) to provide hardware-assisted virtualization.

- **Kernel Integration**: KVM is integrated into the Linux kernel, which means it leverages the kernel's functionality and benefits from ongoing kernel improvements. This integration provides better performance and stability for virtualized environments.

- **Full Virtualization**: KVM supports full virtualization, which allows guest operating systems to run unmodified. This means you can run a variety of operating systems, including Linux, Windows, and others, as virtual machines on a KVM-enabled host.

- **Performance**: KVM is known for its high performance, thanks to its hardware-assisted virtualization support and tight integration with the Linux kernel. This allows for efficient resource utilization and minimal overhead when running virtualized workloads.

- **Management Tools**: KVM can be managed through various tools, including command-line utilities like virsh and graphical interfaces like Virt-Manager. These tools provide administrators with the ability to create, configure, and manage virtual machines on KVM hosts.

Overall, KVM is a powerful and versatile virtualization solution for Linux-based systems, offering performance, flexibility, and ease of management for virtualized environments.

## Installation

### Check Virtualization Support

Before installing KVM, ensure that your processor supports virtualization and it is enabled in the BIOS settings. Most modern processors support virtualization, but it's good to double-check.

For detailed information about checking your hardware please refer to the [Arch Wiki - Cheking support for KVM](https://wiki.archlinux.org/title/KVM#Checking_support_for_KVM).

### Install Required Packages

Open a terminal and install the necessary packages. This includes the QEMU disk image utility `qemu`, the KVM kernel module `kvm`, and the libvirt virtualization API and management tool `libvirt`.

{{< highlight shell "linenos=false" >}}
sudo pacman -S virt-manager virt-viewer qemu dnsmasq bridge-utils
{{< / highlight >}}

### Configure libvirt Service

Libvirt is a toolkit to interact with virtualization capabilities of the Linux kernel. Enable the libvirt service to manage virtual machines.

{{< highlight shell "linenos=false" >}}
sudo systemctl enable --now libvirtd.service
{{< / highlight >}}

Enable autostart for the default NAT virtual network for your VMs:

{{< highlight shell "linenos=false" >}}
sudo virsh net-start default
sudo virsh net-autostart default
{{< / highlight >}}

Then edit the libvirt config at `/etc/libvirt/libvirtd.conf`, and set the parameters:

```bash
unix_sock_group = "libvirt"
unix_sock_rw_perms = "0770"
```

To actually make configurtion above work add your current user to the `libvirt` group:

{{< highlight shell "linenos=false" >}}
sudo usermod -a -G libvirt $(whoami)
newgrp libvirt
{{< / highlight >}}

Then finally restart the libvirt daemon to apply the changes:

{{< highlight shell "linenos=false" >}}
sudo systemctl restart libvirtd.service
{{< / highlight >}}

After that you should be able to launch `virt-manager` and use KVM virtualization, but if you see some errors try rebooting your machine, if this does not help review your libvirt daemon logs and configuration.

### Enable nested virtualization (optional)

Nested virtualization enables existing virtual machines to be run on third-party hypervisors and on other clouds without any modifications to the original virtual machines or their networking. 

To enable it (non-permanently) use the following terminal commands:

{{< highlight shell "linenos=false" >}}
sudo modprobe -r kvm_intel  
sudo modprobe kvm_intel nested=1
{{< / highlight >}}

Then to verify that it is enabled, check the output of the command:

{{< highlight shell "linenos=false" >}}
cat /sys/module/kvm_intel/parameters/nested
{{< / highlight >}}

it should print `Y` as output if Nested virtualization is enabled.

To make this change permanently applied when your machine is booted use command:

{{< highlight shell "linenos=false" >}}
echo "options kvm-intel nested=1" | sudo tee /etc/modprobe.d/kvm-intel.conf
{{< / highlight >}}

## Reference

- [Arch Wiki - KVM](https://wiki.archlinux.org/title/KVM).
- [Wikipedia - KVM](https://en.wikipedia.org/wiki/Kernel-based_Virtual_Machine).
- [Kernel Virtual machine source code](https://git.kernel.org/pub/scm/virt/kvm/kvm.git).
