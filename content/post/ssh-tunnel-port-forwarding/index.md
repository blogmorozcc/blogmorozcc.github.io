+++
title = "Port forwarding using an SSH tunnel"
date = "2016-09-26"
tags = [
    "Linux",
    "SSH",
]
categories = [
    "Linux",
    "Networking",
]
image = "header.webp"
+++

## Introduction

SSH Tunnels allow you to forward specific ports on a remote server or locally. This is very convenient when we need to get to a specific server in the local network.

Technically, it is possible to forward both local and remote ports. We will consider both cases.

## Local port forwarding

Let's imagine the situation when we are inside a local network, where access to the Internet is blocked by a firewall for all but one server that has direct access to the Internet. We have SSH access to this server. Our task is to connect to a remote server that is on an external SSH network.

For example:

{{< highlight shell "linenos=false" >}}
ssh -f -N -L 2222:212.212.212.212:22 user@111.111.111.111
{{< / highlight >}}

This command will create a tunnel by opening port 22 of the remote server through the local server, and we can connect to the remote server through port 2222, which will listen on the local interface of our PC.

We should leave the terminal with the tunnel session running, and in the new terminal we can connect to the remote server with the command:

{{< highlight shell "linenos=false" >}}
ssh -p2222 127.0.0.1
{{< / highlight >}}

Finally, we have SSH access to the remote server.

## Remote port forwarding

This case is the opposite of local port forwarding. Let's imagine the same local network and remote server, only now the local PC has access to the Internet through NAT. Let's say that a system administrator who has physical access to a remote server needs to RDP to computer 192.168.0.2, but NAT will not allow him to do so directly.

Consider an example where there is an RDP service that by default is running on local port 3389. Let's send it to remote port 3333.

{{< highlight shell "linenos=false" >}}
ssh -f -N -R 3333:127.0.0.1:3389 username@212.212.212.212
{{< / highlight >}}

After setting up such a tunnel, the sysadmin sitting behind the remote server will be able to connect to us by RDP using the address 127.0.0.1:3333 in the RDP client.

## Conclusions

These simple techniques of tunneling through the SSH protocol allow you to redirect the ports of a local or remote service as you like, which can be useful if you need to bypass certain network restrictions, such as NAT.
