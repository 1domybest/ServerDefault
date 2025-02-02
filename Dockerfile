# 서버설정
# 베이스 이미지 선택 (필요에 따라 변경 가능)
FROM ubuntu:latest

# 작업 디렉토리 설정
WORKDIR /app

RUN mkdir -p /home/ubuntu/compose

# 현재 디렉토리의 compose 폴더를 컨테이너 내부로 복사
COPY compose/ /home/ubuntu/compose/

COPY main_docker_compose.yml /home/ubuntu/

# 기본 명령어 설정 (필요에 따라 수정)
CMD ["bash"]

# 1. Nginx 설정 디렉토리 생성
RUN mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled

# 2. 현재 디렉토리의 domain 폴더 안의 모든 파일을 sites-available로 복사
COPY sites-available/ /etc/nginx/sites-available/

# 3. 심볼릭 링크를 생성하여 sites-enabled에서 활성화
RUN ln -s /etc/nginx/sites-available/* /etc/nginx/sites-enabled/

# 기존 기본 설정 파일 제거 (선택 사항)
RUN rm -f /etc/nginx/conf.d/default.conf

# 프로젝트 디렉토리의 default.conf를 Nginx 설정 폴더로 복사
COPY default.conf /etc/nginx/conf.d/default.conf
