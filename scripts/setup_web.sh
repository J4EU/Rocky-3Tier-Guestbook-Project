#!/bin/bash

# Web 서버에 할당할 IP 변수 설정
MY_IP="192.168.219.210"
GATEWAY="192.168.219.1"
DNS="8.8.8.8"

# nmcli - 고정 IP 설정
INTERFACE=$(nmcli -t -f DEVICE device | head -n 1)
sudo nmcli con mod "$INTERFACE" ipv4.addresses "${MY_IP}/24"
sudo nmcli con mod "$INTERFACE" ipv4.gateway "$GATEWAY"
sudo nmcli con mod "$INTERFACE" ipv4.dns "$DNS"
sudo nmcli con mod "$INTERFACE" ipv4.method manual
sudo nmcli con up "$INTERFACE"

# 공통 설정 스크립트
bash ./common_setup.sh

# Nginx 설치
sudo dnf update -y
sudo dnf install -y nginx
sudo systemctl enable --now nginx

# 방화벽 설정 - HTTP 포트 개방
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload

# 설정 파일 및 소스 배포
sudo cp ../configs/nginx_default.conf /etc/nginx/conf.d/default.conf
sudo cp ../frontend/index.html /usr/share/nginx/html/index.html

# SELinux 설정
sudo setsebool -P httpd_can_network_connect 1
sudo chcon -t httpd_sys_content_t /usr/share/nginx/html/index.html

# Nginx 재시작 - 설정 적용
sudo systemctl restart nginx

echo "--- WEB Server 설정 완료! ---"