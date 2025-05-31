#!/bin/bash
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 3129
sudo iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 3130
sudo iptables -A INPUT -p icmp --icmp-type timestamp-request -j DROP
sudo iptables -A OUTPUT -p icmp --icmp-type timestamp-reply -j DROP
iptables -t nat -v -L -n --line-number
