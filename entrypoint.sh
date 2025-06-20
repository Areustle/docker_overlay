#!/bin/sh

# readonly
LOWER=/mnt/lower
# these 2 need to be onthe same fs on the host system
UPPER=/mnt/overlayfs/upper
WORK=/mnt/overlayfs/work

# for users you probably want to name this "data" or similar
MERGED=/mnt/merged

mkdir -p "$LOWER" "$UPPER" "$WORK" "$MERGED"

# actually do teh overlay mount
mount -t overlay overlay -o lowerdir="$LOWER",upperdir="$UPPER",workdir="$WORK" "$MERGED"

exec "$@"
