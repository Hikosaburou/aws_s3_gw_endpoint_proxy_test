#!/bin/bash
yum update -y
yum install -y squid
systemctl start squid
systemctl enable squid
