+++
title = "Install Linux ZEN kernel on Arch Linux to improve performance"
date = "2024-03-25"
tags = [
    "Linux",
    "Kernel",
    "Zen",
]
categories = [
    "Linux",
]
image = "header.png"
+++

## What is Linux Zen Kernel ?

The Linux Zen Kernel is a customized version of the Linux kernel that focuses on providing improved performance, responsiveness, and flexibility for desktop and workstation users. It is developed and maintained by the Zen Kernel project, which aims to optimize the kernel for desktop use cases.

The Zen Kernel incorporates various patches and optimizations aimed at reducing latency, improving system responsiveness, and enhancing overall system performance. These optimizations may include tweaks to the scheduler, I/O scheduler improvements, CPU scheduling enhancements, and other performance-related adjustments.

Users who prioritize desktop or workstation performance and responsiveness may choose to use the Linux Zen Kernel over the standard Linux kernel provided by their distribution. However, it's important to note that the Zen Kernel is a third-party modification and may not be officially supported by all Linux distributions. Users interested in trying out the Zen Kernel should review documentation and instructions provided by the Zen Kernel project or their specific distribution's community.

## Key benefits

Some of the key features and optimizations typically found in the Linux Zen kernel include:

- Low-Latency Patchset: These patches aim to reduce the latency of the kernel, improving responsiveness, which is particularly important for interactive desktop use, audio processing, and gaming.

- BFQ I/O Scheduler: The Zen kernel often includes the BFQ (Budget Fair Queueing) I/O scheduler, which prioritizes I/O requests based on the process generating them, aiming to provide smoother system performance, especially during multitasking or when dealing with interactive applications.

- Additional CPU Schedulers: In some cases, Zen kernel includes alternative CPU scheduling algorithms or optimizations to improve multitasking performance and responsiveness.

- Preemption and Real-Time Support: The kernel may include patches to enhance preemption and real-time capabilities, reducing delays and improving responsiveness for time-sensitive tasks.

- Tuned Defaults: Some kernel parameters are tuned by default to better suit desktop and multimedia workloads.

- Stability and Reliability: While emphasizing performance improvements, Zen kernel developers typically ensure that stability and reliability are maintained, though users should always be aware that any kernel modifications may introduce risks.

## Installation (Arch Linux)

Linux Zen Kernel is included in Arch Linux pacman package manager and can be easily installed using pacman:

{{< highlight shell "linenos=false" >}}
sudo pacman -S linux-zen linux-zen-headers
{{< / highlight >}}

After that kernel is actually installed on your system, but now it's time to tell your bootloader to boot with Linux Zen Kernel instead of the default one. This can depend on your bootloader, in my case I am using `systemd-boot` as my bootloader.

The boot entries are located at `/boot/loader/entries` directory, so navigate there:

{{< highlight shell "linenos=false" >}}
cd /boot/loader/entries/
{{< / highlight >}}

And list all your boot entries:

{{< highlight shell "linenos=false" >}}
ls -la
{{< / highlight >}}

In my case I have only one entry `arch.conf`:

```bash
drwxr-xr-x 2 root root 4096 Feb 24 14:42 .
drwxr-xr-x 3 root root 4096 Mar 25 20:15 ..
-rwxr-xr-x 1 root root  208 Mar 18 18:31 arch.conf
```

I recommend to leave the original boot entry and original Linux Kernel for the backup, so if new kernel fails to boot you will always have an option to boot from the stock kernel in the bootloader.

Create a duplicate of the original boot entry file:

{{< highlight shell "linenos=false" >}}
sudo cp arch.conf arch-zen.conf
{{< / highlight >}}

Then edit the `arch-zen.conf` file using your text editor of choice, in my case I use nano like this:

{{< highlight shell "linenos=false" >}}
sudo nano arch-zen.conf
{{< / highlight >}}

Then modify the config and replace 3 params (title, linux, initrd) according to the example above:

Before (original `arch.conf` file):

```bash
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
```

After (modify in `arch-zen.conf` file):

```bash
title Arch Linux Zen
linux /vmlinuz-linux-zen
initrd /initramfs-linux-zen.img
```

After saving the file reboot your system, and select the `Arch Linux Zen` during boot.

## Conclusion

To sum up, the Linux Zen kernel is tailored for users who prioritize desktop responsiveness, multimedia performance, and gaming experience. However, users should carefully evaluate whether the specific optimizations and patches provided by the Zen kernel align with their needs and preferences, as some features may trade off general-purpose performance or compatibility for specialized use cases.
