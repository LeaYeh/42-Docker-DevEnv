#!/bin/bash

# Copy all files mounted in /mnt to user's home directory
mount_dir="/mnt"
dest_dir="$HOME"
shopt -s dotglob nullglob
for item_path in "$mount_dir"/*; do
    item=$(basename "$item_path")
    cp -ru "$item_path" "$dest_dir" \
    && chown -R "$USER:$USER" "$dest_dir/$item"
done
shopt -u dotglob nullglob

exec "$@"
