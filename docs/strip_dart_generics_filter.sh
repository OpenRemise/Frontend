#!/usr/bin/env bash
# Strips generics from class definitions for Doxygen
for f in "$@"; do
    sed -E 's/(class[[:space:]]+[A-Za-z0-9_]+)<[^>]+>/\1/' "$f"
done
