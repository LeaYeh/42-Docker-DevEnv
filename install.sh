#!/usr/bin/env bash

mkdir -p .devcontainer

curl -fsSL https://raw.githubusercontent.com/LeaYeh/42-Docker-DevEnv/main/.devcontainer/devcontainer.json -o .devcontainer/devcontainer.json
curl -fsSL https://raw.githubusercontent.com/LeaYeh/42-Docker-DevEnv/main/.devcontainer/Dockerfile -o .devcontainer/Dockerfile
curl -fsSL https://raw.githubusercontent.com/LeaYeh/42-Docker-DevEnv/main/.devcontainer/entrypoint.sh -o .devcontainer/entrypoint.sh
