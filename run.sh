# curl -fsSL https://raw.githubusercontent.com/LeaYeh/42-Docker-DevEnv/master/Dockerfile -o Dockerfile
# curl -fsSL https://raw.githubusercontent.com/LeaYeh/42-Docker-DevEnv/master/docker-compose.yml -o docker-compose.yml

# docker build --build-arg USER=$USER -t develop-env .
docker build --progress=plain --build-arg USER=$USER -t develop-env .
# docker exec -it -u leayeh <container_id> /bin/bash
docker-compose up -d run-container
