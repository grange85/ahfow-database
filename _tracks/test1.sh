#!/bin/bash
for f in *; do
    d="$(ggrep -Po 'wp_post_name: \K.*?(.*$)' $f).md"
    if [ ! -f "$d" ]; then
        mv "$f" "$d"
    else
        echo "File '$d' already exists! Skiped '$f'"
    fi
done
