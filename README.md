# squid-cache-proxy

This project uses Squid 🦑 as a proxy to manage DNS-filtered firewall rules, serving as an alternative to AWS Network Firewall.

## About
 - Using the OS as Amazon Linux 2023
 - Installed squid --version;  Squid Cache: Version 6.13
 - Binary uses OpenSSL 3.2.2 4 Jun 2024

## Files

- `squid.conf`: Main Squid proxy configuration file, including HTTP/HTTPS ports, SSL bumping, ACLs, and access rules.
- `iptables.sh`: Shell script to set up iptables rules for redirecting HTTP (port 80) and HTTPS (port 443) traffic to Squid's transparent proxy ports, and to block certain ICMP types.

## Key Features

- Transparent HTTP/HTTPS proxying with SSL bumping
- DNS filtering via Squid ACLs and whitelists
- Customizable access controls and logging
- Integration with system startup via cron and shell scripts

## Usage

1. Configure Squid using `squid.conf`.
2. Set up SSL certificates for SSL bumping (see Squid documentation).
3. Use `iptables.sh` to redirect traffic and block unwanted ICMP types.
4. Ensure Squid is running as a service.

## Example iptables.sh

```bash
#!/bin/bash
# Redirect HTTP traffic (port 80) to Squid's transparent proxy port 3129
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 3129
# Redirect HTTPS traffic (port 443) to Squid's SSL bump port 3130
sudo iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 3130
# Block ICMP timestamp requests and replies for security
sudo iptables -A INPUT -p icmp --icmp-type timestamp-request -j DROP
sudo iptables -A OUTPUT -p icmp --icmp-type timestamp-reply -j DROP
# List current NAT table rules with line numbers
iptables -t nat -v -L -n --line-number
```

## Generate SSL Certificate

To generate the SSL certificate and key file for Squid at `/etc/squid/ssl/squid.pem`, you can use OpenSSL. This file acts as a Certificate Authority (CA) for Squid’s SSL bumping feature.

**Steps to generate the certificate:**

1. **Create the directory if it doesn’t exist:**

   ```bash
   sudo mkdir -p /etc/squid/ssl
   ```

2. **Generate a new private key and self-signed CA certificate (valid for 10 years), and combine them into `squid.pem`:**

   ```bash
   sudo openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
     -keyout /etc/squid/ssl/squid.key \
     -out /etc/squid/ssl/squid.crt \
     -subj "/C=US/ST=State/L=City/O=Organization/CN=SquidProxyCA"

   sudo cat /etc/squid/ssl/squid.key /etc/squid/ssl/squid.crt | sudo tee /etc/squid/ssl/squid.pem > /dev/null
   ```

3. **Set the correct permissions:**

   ```bash
   sudo chmod 600 /etc/squid/ssl/squid.pem
   sudo chown squid:squid /etc/squid/ssl/squid.pem
   ```

## Whitelisting Domains for Proxy Access

The Squid proxy uses a whitelist file to control which domains are allowed through the proxy. This is configured in `squid.conf` using the following line:

```
acl allowed_sites dstdomain "/etc/squid/whitelist.conf"
http_access allow allowed_sites
```

To whitelist domains, add them (one per line) to `/etc/squid/whitelist.conf`.

Example `/etc/squid/whitelist.conf`:
```
example.com
mycompany.com
*.trustedsite.org
```

Only domains listed in this file will be accessible through the proxy.
