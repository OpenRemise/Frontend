#!/usr/bin/env bash
# Strips annotations and generics from class definitions for Doxygen
for f in "$@"; do
    sed -E '
        # Remove lines with @Something(...) annotations
        s/^@[A-Za-z0-9_]+(\([^)]*\))?[[:space:]]*//;

        # Remove generic type parameters from class declarations
        s/(class[[:space:]]+[A-Za-z0-9_]+)<[^>]*>/\1/;
    ' "$f"
done