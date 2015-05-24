#!/bin/bash
for f in *; do
    d=`tr -dc '[[:print:]]' <<< "$f"`
    echo $d
    if [ ! -f "$d" ]; then
        mv "$f" "$d"
    else
        echo "File '$d' already exists! Skiped '$f'"
    fi
done 
