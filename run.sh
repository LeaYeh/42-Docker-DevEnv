#!/usr/bin/env bash

# Download latest Dockerfile and docker-compose.yml
curl -fsSL https://raw.githubusercontent.com/LeaYeh/42-Docker-DevEnv/main/Dockerfile -o Dockerfile
curl -fsSL https://raw.githubusercontent.com/LeaYeh/42-Docker-DevEnv/main/docker-compose.yml -o docker-compose.yml

# Ensure directories and files to be mounted exist
mkdir -p "${HOME}/.ssh"
touch "${HOME}/.gitconfig" "${HOME}/.zshrc"

# Build and run the container
docker-compose up --build -d run-container

# Print helpful message
echo "Container is running! To attach to it, use:"
echo "docker exec -it \$(docker-compose ps -q run-container) /bin/zsh"
echo
echo "Check the README how to attach to the container with VS Code."
