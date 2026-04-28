#!/usr/bin/env bash

# This is intended to be run in the buildroot-duetscreen root directory

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <duetscreen_ip_address>" >&2
  exit 1
fi

ip_address="$1"

SSH_CMD="ssh"
SCP_CMD="scp"

# In WSL, interactive shells may use *.exe backends via aliases/functions.
# Scripts do not inherit those, so detect and use them explicitly.
if command -v ssh.exe >/dev/null 2>&1 && command -v scp.exe >/dev/null 2>&1; then
  SSH_CMD="ssh.exe"
  SCP_CMD="scp.exe"
fi

echo "Stopping DuetScreen on ${ip_address}..."
"$SSH_CMD" "root@${ip_address}" '/etc/init.d/S21DuetScreenMonitor stop; start-stop-daemon -K -n DuetScreen' || true

echo
echo "Stripping debug symbols..."
cp output/target/usr/bin/DuetScreen output/target/usr/bin/DuetScreen.stripped
output/host/bin/arm-buildroot-linux-gnueabihf-strip output/target/usr/bin/DuetScreen.stripped

echo "Copying stripped binary to ${ip_address}..."
"$SCP_CMD" output/target/usr/bin/DuetScreen.stripped "root@${ip_address}:/usr/bin/DuetScreen"
rm output/target/usr/bin/DuetScreen.stripped

echo "Successfully pushed DuetScreen to ${ip_address}"
