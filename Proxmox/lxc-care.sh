#!/bin/bash
# curl -sL https://raw.githubusercontent.com/ScriptSchublade/LazyScripts/main/Proxmox/lxc-care.sh | bash
echo "Starting: $1";
/usr/sbin/pct start $1;
pct exec $1 -- bash -c 'apt-get update && apt-get dist-upgrade -y && apt autoremove --purge && apt-get clean -y';
/usr/sbin/pct stop $1;
