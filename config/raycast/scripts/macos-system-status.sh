#!/bin/bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Check macOS System Status
# @raycast.mode fullOutput
# @raycast.packageName macOS
# @raycast.icon 🩺

set -euo pipefail

printf 'macOS: '
sw_vers -productVersion
printf 'Host: '
scutil --get ComputerName 2>/dev/null || hostname -s
printf 'Uptime: '
uptime | sed 's/^.*up /up /'
printf '\nDisk (/):\n'
df -h /
printf '\nBattery:\n'
pmset -g batt 2>/dev/null || printf 'Battery information unavailable\n'
printf '\nNetwork interfaces:\n'
ifconfig | awk '/^[a-z0-9]+:/{iface=$1; sub(":","",iface)} /status: active/{print iface ": active"}'
