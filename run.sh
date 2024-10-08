#!/usr/bin/env bash

curl -fsSL https://raw.githubusercontent.com/LeaYeh/42-Docker-DevEnv/main/Dockerfile -o Dockerfile
curl -fsSL https://raw.githubusercontent.com/LeaYeh/42-Docker-DevEnv/main/docker-compose.yml -o docker-compose.yml

docker build --build-arg USER=$USER -t develop-env .
# docker build --progress=plain --build-arg USER=$USER -t develop-env .
# docker exec -it -u leayeh <container_id> /bin/bash
echo "USER=$(whoami)" > .env
docker-compose up --build -d run-container
