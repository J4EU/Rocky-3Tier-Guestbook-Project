#!/bin/bash

# 시스템 업데이트 및 필수 패키지 설치
sudo dnf update -y && sudo dnf upgrade -y
sudo dnf install -y epel-release
sudo dnf install -y vim htop net-tools curl wget openssh-server bash-completion

# 시간대 설정 (서울))
sudo timedatectl set-timezone Asia/Seoul

# SSH 서비스 활성화
sudo systemctl enable --now sshd

# 불필요한 파일 정리
sudo dnf autoremove -y && sudo dnf clean all

# 머신 ID 초기화 (복제 대비)
sudo truncate -s 0 /etc/machine-id