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

# Set up francinette aliases
rc_files=( "$HOME/.bashrc" "$HOME/.config/fish/config.fish" "$HOME/.zshrc" )
for rc_file in "${rc_files[@]}"; do
    mkdir -p "$(dirname "$rc_file")"
    if ! grep "francinette=" "$rc_file" &> /dev/null; then
        printf "\nalias francinette=%s/francinette/tester.sh\n" "$HOME" >> "$rc_file"
    fi
    if ! grep "paco=" "$rc_file" &> /dev/null; then
        printf "\nalias paco=%s/francinette/tester.sh\n" "$HOME" >> "$rc_file"
    fi
    first_level=${rc_file#"$HOME/"}
    first_level=${first_level%%/*}
    chown -R "$USER:$USER" "$HOME/$first_level"
done

exec "$@"
