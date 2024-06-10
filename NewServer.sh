# /bin/sh

apt-get update && apt-get dist-upgrade -y && apt autoremove --purge && apt-get clean
apt-get install curl mc htop
timedatectl set-timezone Europe/Berlin
fallocate -l 1G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
echo 'vm.swappiness = 10' | sudo tee -a /etc/sysctl.conf
echo 'vm.vfs_cache_pressure=50' | sudo tee -a /etc/sysctl.conf
curl -fsSL https://gist.githubusercontent.com/vsefer/f2696e997e1ab4316a50/raw/78544b83cb85428ba057fb02f8bbdd2bae7681db/htz-bashrc -o /root/.bashrc
