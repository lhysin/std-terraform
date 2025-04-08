#!/bin/bash

# 기본 설정 값들
AWS_REGION="ap-northeast-2"
ECR_ACCOUNT_ID="627500151784"
ECR_REPO_NAME="cjo-std-ecr-ontrust"
DOCKER_IMAGE_NAME="cjo-std-ecr-ontrust"
JAVA_VERSION="17"
TIMEZONE="Asia/Seoul"

# 파라미터로 받은 Git 주소
GIT_REPO=$1

# Git 리포지토리 클론
echo "Cloning the repository from $GIT_REPO"
git clone $GIT_REPO

# 클론 후 루트 폴더로 이동
REPO_NAME=$(basename $GIT_REPO .git)
cd $REPO_NAME || exit

# application.yml 파일 경로
YML_PATH="src/main/resources/application.yml"

# application.yml 파일에서 포트값 추출
if [ ! -f "$YML_PATH" ]; then
  echo "Error: $YML_PATH file not found"
  exit 1
fi

# 포트값 추출
PORT=$(grep '^\s*port:' "$YML_PATH" | awk '{print $2}')

if [ -z "$PORT" ]; then
  echo "Error: Could not find server port in application.yml"
  exit 1
fi

echo "Found server port: $PORT"

# Dockerfile 생성
echo "Creating Dockerfile"

cat <<EOF > Dockerfile
FROM openjdk:17-jdk-slim-buster
ENV TZ=Asia/Seoul
COPY target/*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
EXPOSE $PORT
EOF

echo "build maven"
mvn clean package

# aws profile
# export AWS_PROFILE=

# ECR 로그인
echo "Logging into AWS ECR"
echo "aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
#aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Docker 이미지 빌드 및 푸시
echo "Building and pushing the Docker image"

docker build -t $DOCKER_IMAGE_NAME:$REPO_NAME . \
  && docker tag $DOCKER_IMAGE_NAME:$REPO_NAME $ECR_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:$REPO_NAME \
  && docker push $ECR_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:$REPO_NAME

# 로컬 Git 레포지토리 삭제
echo "Deleting local Git repository..."
cd ..
rm -rf $REPO_NAME

# 로컬 Docker 이미지 삭제
echo "Deleting local Docker images..."
docker rmi $(docker images -q)

# 중지된 컨테이너 삭제
echo "Deleting stopped Docker containers..."
docker container prune -f

echo "Deployment and cleanup completed."

# Kubernetes 배포 파일 생성
echo "Creating Kubernetes deployment and service files"

# $REPO_NAME 폴더 생성
mkdir -p $REPO_NAME

# deployment.yaml 파일 생성
cat <<EOF > $REPO_NAME/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $REPO_NAME
  labels:
    app: $REPO_NAME
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $REPO_NAME
  template:
    metadata:
      labels:
        app: $REPO_NAME
    spec:
      containers:
        - name: $REPO_NAME
          image: $ECR_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:$REPO_NAME
          ports:
            - containerPort: $PORT
EOF

# service.yaml 파일 생성
cat <<EOF > $REPO_NAME/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: $REPO_NAME
spec:
  selector:
    app: $REPO_NAME
  ports:
    - port: 80
      targetPort: $PORT
  type: ClusterIP
EOF

# kustomization.yaml 파일 생성
cat <<EOF > $REPO_NAME/kustomization.yaml
resources:
  - deployment.yaml
  - service.yaml
EOF
