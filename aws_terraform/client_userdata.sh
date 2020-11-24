#!/bin/bash
yum update -y
echo "export HTTP_PROXY=http://${proxy_dns}:3128" >> /home/ec2-user/.bashrc
echo "export HTTPS_PROXY=http://${proxy_dns}:3128" >> /home/ec2-user/.bashrc
echo "export NO_PROXY=169.254.169.254" >> /home/ec2-user/.bashrc
