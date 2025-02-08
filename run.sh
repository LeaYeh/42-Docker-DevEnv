#!/usr/bin/env bash

# Download latest devcontainer and docker-compose.yml
bash -c "$(curl -fsSL https://raw.githubusercontent.com/LeaYeh/42-Docker-DevEnv/main/install.sh)"
curl -fsSL https://raw.githubusercontent.com/LeaYeh/42-Docker-DevEnv/main/docker-compose.yml -o docker-compose.yml

# Ensure directories and files to be mounted exist
mkdir -p \
    "$HOME/.config/fish/" \
    "$HOME/.ssh"
touch \
    "$HOME/.bashrc" \
    "$HOME/.gitconfig" \
    "$HOME/.zsh_history" \
    "$HOME/.zshrc"

# Build and run the container
docker-compose up --build -d 42-docker-devenv

# Print helpful message
echo "Container is running! To attach to it, use:"
echo "docker exec -it \$(docker-compose ps -q 42-docker-devenv) /bin/zsh"
echo
echo "Check the README how to attach to the container with VS Code."
