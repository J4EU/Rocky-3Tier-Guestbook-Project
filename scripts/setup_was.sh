#!/bin/bash

# WAS 서버에 할당할 IP 변수 설정
MY_IP="192.168.219.220"
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

# 패키지 및 Python 설치
sudo dnf update -y
sudo dnf install -y python3 python3-pip

# 의존성 라이브러리 설치
pip3 install -r ../backend/requirements.txt

# 방화벽 설정 - 8000 포트 개방
sudo firewall-cmd --permanent --add-port=8000/tcp
sudo firewall-cmd --reload

# 환경 변수 복사
cp ../backend/.env.example ../backend/.env
echo " --- 주의: .env.example을 복사했습니다. 실제 DB 정보를 입력하세요. --- "

# uvicorn 백그라운드 실행
cd ../backend && nohup uvicorn main:app --host 0.0.0.0 --port 8000 > was.log 2>&1 &