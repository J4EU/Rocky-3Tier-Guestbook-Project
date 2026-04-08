# 3-Tier Guestbook Project
Rocky Linux 9 환경에서 Web-WAS-DB 3계층 구조를 구축하는 실습 프로젝트입니다.

## 1. 사전 준비
- **고정 IP 설계 필수**: Web, WAS, DB 서버의 IP를 미리 고정해야 함
    - (예시: Web `.210` / WAS `.220` / DB `.230`)

- **환경 설정**: `backend/.env.example` 내용을 본인 환경에 맞춰 수정해야 함
    - 스크립트 실행 시 `.env`로 자동 복사됨

## 2. 구축 순서
의존성 관계에 따라 아래 순서대로 스크립트 실행을 권장함

1. **DB Server**: `scripts/setup_db.sh` 실행 (MariaDB 설치 및 테이블 생성)
2. **WAS Server**: `scripts/setup_was.sh` 실행 (Python 환경 구축 및 서버 가동)
3. **Web Server**: `scripts/setup_web.sh` 실행 (Nginx 설정 및 SELinux 보안 적용)

## 3. 주요 체크리스트 (삽질 방지)
- **502 에러 발생 시**: Web 서버에서 `httpd_can_network_connect` 허용 여부 확인해야 함
- **DB 연결 실패 시**: `.env`에 기재된 DB 서버 IP와 비밀번호가 실제와 일치하는지 확인해야 함
- **한글 깨짐 발생 시**: DB 테이블 생성 시 `utf8mb4` 설정이 반영되었는지 확인해야 함
