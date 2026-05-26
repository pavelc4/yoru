#!/usr/bin/env sh

cat ~/.local/state/yoru/sequences.txt 2>/dev/null

exec "$@"
