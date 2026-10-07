#!/bin/sh
set -eu

# mihomo installs a policy rule that sends ordinary container egress through
# its TUN. Replies for the published HTTP port must use the host's main route.
bridge=workbuddy2api0

for _ in $(seq 1 60); do
    ip link show "$bridge" >/dev/null 2>&1 && break
    sleep 2
done

if ! ip link show "$bridge" >/dev/null 2>&1; then
    echo "Docker bridge $bridge is not present yet" >&2
    exit 1
fi

if ! ip -o rule show | grep -Fq "iif $bridge"; then
    ip rule add pref 51 iif "$bridge" lookup main
fi
