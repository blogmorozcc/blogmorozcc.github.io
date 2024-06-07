+++
title = "Listen HTTPS and OpenVPN server on same 443 port using HAProxy load balancer"
date = "2024-06-07"
tags = [
    "HAProxy",
    "VPN",
    "OpenVPN",
    "Load balancing",
    "HTTPS",
    "SSL Termination",
    "Network traffic",
    "Web Server",
]
categories = [
    "Linux",
    "Networking",
    "Cybersecurity",
]
image = "header.png"
+++

## Introduction

### Purpose of having OpenVPN and Web server at port 443

Let's imagine that you have the OpenVPN server listening on port 1194, and you are connecting from some public or work network not controlled by you. In this case there may be a situation where only outcoming connections to common ports are allowed (for example 80 and 443 so user can only surf the web), so you can not connect to your OpenVPN server and encrypt your traffic from network administrator. 

In this particular case you can try moving your OpenVPN service to listen on port 443. But what to do if you also use your server for hosting some websites so port 443 is already in use? To solve this problem it is reasonable to use some proxy or load balancing solution and redirect network traffic from incoming port 443 to appropriate local service port 1194, 8080, etc. 

### How it works

You can configure HAProxy to terminate SSL and then route traffic based on SNI (Server Name Indication) or other criteria to either your OpenVPN server or to different websites. Here's a high-level overview of how you can achieve this:

1. **SSL Termination:** HAProxy will handle incoming SSL connections on port 443. It will decrypt the traffic, inspect it, and then decide where to forward it.

2. **Traffic Routing:** Based on criteria such as the requested hostname or the content of the initial packets, HAProxy can route traffic to different backend servers:

- HTTPS traffic can be forwarded to your web servers.
- OpenVPN traffic can be forwarded to the OpenVPN server.

3. **Hiding VPN Traffic:** By serving OpenVPN on port 443, it becomes harder for network administrators to distinguish between regular HTTPS traffic and VPN traffic. This can help in environments where VPN usage is restricted or monitored.

## Setup 

The setup guide assumes that you already have up and running this services on your system:

- OpenVPN service running in TCP mode.
- One or multiple http web services.

Personally I run every web service as a docker (docker compose) containers and bind their http ports to some free port on localhost (for example multiple web apps are on local interface, but different port `http://localhost:20001`, `http://localhost:20002`, etc).

### Install HAProxy

First, install HAProxy on your system:

{{< highlight shell "linenos=false" >}}
sudo apt install haproxy
{{< / highlight >}}

Then enable and start HAProxy systemd daemon:

{{< highlight shell "linenos=false" >}}
sudo systemctl enable --now haproxy.service
{{< / highlight >}}

### Configure HAProxy

Plaсe your SSL certificates to `/etc/ssl/haproxy`. The directory and certificates should be accessible only for root user. For example, if you have `domain1.com`, `domain2.com` domains that you want to host web services for, you should have certificate and key pairs for each domain in the directory with appropriate naming, for example:

- domain1.com.pem
- domain1.com.pem.key
- domain2.com.pem
- domain2.com.pem.key

Then edit the file `/etc/haproxy/haporxy.cfg`, and add the needed sections.

### Define backends for Web apps and OpenVPN.

For example, if I have 2 web sites listening on ports 20001, 20002 and OpenVPN listening on port 1194, the configuration will be:

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

### Configure HTTPS balancing

Next we need to create a frontend which will be bound to `localhost:8443` and will manage redirect based on domain. It will allow to host web apps for multiple domains. Also backend for `localhost:8443` should be created, it will be used later to connect from port frontend which will be listened on incoming port 443. 

In this example connection is redirected to corresponding web app based on domain SNI check, for example:

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

### Configure incoming frontend for public 443 port

This is main frontend which is listened on public 443 port and manages regirect to needed backend based on SNI. 

First it checks if SNI ends with some of mathing domains (domain1.com or domain2.com), this kind of checks allows to host any subdomain in future (for example `dev.domain1.com`, `prod.domain2.com`, etc). And in the end if no SNI check passed it means that we have a connection to OpenVPN, this rule is defined as the default.

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

### Full configuration example

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

## Extras

### How to validate HAProxy configuration

HAProxy can validate the configuration file and tell you if there is any error. 

To check the configuration, run:

{{< highlight shell "linenos=false" >}}
sudo haporxy -c -f /etc/haproxy/haproxy.cfg
{{< / highlight >}}

### How to apply HAProxy changes 

To apply changes to HAProxy configuration, simply restart the daemon:

{{< highlight shell "linenos=false" >}}
sudo systemctl restart --now haproxy.service
{{< / highlight >}}

## Conclusion

Using HAProxy to handle SSL termination and multiplexing traffic over port 443 can be an effective way to hide VPN usage and bypass network restrictions. This setup can be particularly useful in environments where only port 443 is open or VPN traffic is actively monitored and restricted. By carefully configuring HAProxy, you can create a flexible and secure solution that meets your needs.

### Benefits

1. **Port Multiplexing:** using port 443 for both VPN and web traffic allows you to work around network restrictions that only allow port 443.

2. **Hiding VPN Usage:** by serving OpenVPN on port 443, the VPN traffic blends in with normal HTTPS traffic, making it harder to detect and block.

3. **Flexibility:** you can handle multiple services on a single IP and port, reducing the number of open ports and simplifying firewall rules.

### Considerations

1. **Detection:** while this method can help bypass some restrictions, sophisticated network monitoring tools can still potentially detect OpenVPN traffic based on traffic patterns and behavior, even on port 443.

2. **Performance:** HAProxy needs to decrypt and inspect SSL traffic, which can add overhead. Ensure your server has sufficient resources to handle the additional load.

3. **Security:** terminating SSL at HAProxy means it handles the encryption and decryption. Make sure HAProxy and the server it’s running on are secured and kept up to date.
