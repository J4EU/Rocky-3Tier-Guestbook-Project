#!/bin/bash

# DB 서버에 할당할 IP 변수 설정
MY_IP="192.168.219.230"
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

# MariaDB 설치 및 활성화
sudo dnf update -y
sudo dnf install -y mariadb-server
sudo systemctl enable --now mariadb

# 방화벽 설정 - 3306 포트 개방
sudo firewall-cmd --permanent --add-port=3306/tcp
sudo firewall-cmd --reload

# DB 및 유저 생성
sudo mysql -e "CREATE DATABASE IF NOT EXISTS guestbook;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'guestbook_user'@'%' IDENTIFIED BY 'password123';"
sudo mysql -e "GRANT ALL PRIVILEGES ON guestbook.* TO 'guestbook_user'@'%';"
sudo mysql -e "FLUSH PRIVILEGES;"

# 초기 테이블 생성
if [ -f "./db_init.sql" ]; then
    sudo mysql guestbook < ./db_init.sql
    echo "--- 테이블 생성 완료! ---"
else
    echo "--- db_init.sql 파일을 찾을 수 없습니다. ---"
fi

# my.cnf 설정
sudo mv /etc/my.cnf /etc/my.cnf.bak
sudo cp ../configs/my.cnf /etc/my.cnf
sudo chmod 644 /etc/my.cnf
sudo chown root:root /etc/my.cnf
sudo systemctl restart mariadb

# DB 기본 보안 설정
sudo mysql_secure_installation

echo "--- DB Server 설정 완료! ---"