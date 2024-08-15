# /bin/sh
apt-get update && apt-get dist-upgrade -y && apt autoremove -y --purge && apt-get clean -y
timedatectl set-timezone Europe/Berlin
fallocate -l 1G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
echo 'vm.swappiness = 10' | sudo tee -a /etc/sysctl.conf
echo 'vm.vfs_cache_pressure=50' | sudo tee -a /etc/sysctl.conf
apt-get install -y curl mc htop ca-certificates cron
curl -fsSL https://gist.githubusercontent.com/vsefer/f2696e997e1ab4316a50/raw/78544b83cb85428ba057fb02f8bbdd2bae7681db/htz-bashrc -o /root/.bashrc
(crontab -l 2>/dev/null; echo "45 4 * * * apt-get update && apt-get dist-upgrade -y && apt autoremove -y --purge && apt-get clean -y") | crontab -

# Docker
printf "Install Docker? [y,n]" >&2
read -r doit

case $doit in  
  y|Y) 
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    
    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose
    docker run -d --network host --name watchtower-once -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower:latest --cleanup --include-stopped --run-once
    (crontab -l 2>/dev/null; echo "55 4 * * * docker start watchtower-once -a") | crontab - ;; 
n|N) echo no ;; 
  *) echo dont know ;; 
esac

# Nginx
printf "Install Nginx Proxy? [y,n]" >&2
read -r doit2

case $doit2 in  
  y|Y) 
    sapt install -y snapd nginx
    sudo snap install snapd
    snap install core
    snap install certbot --classic
    snap set certbot trust-plugin-with-root=ok
    sudo ln -s /snap/bin/certbot /usr/bin/certbot
    snap install certbot-dns-cloudflare certbot-dns-netcup
    mkdir -p /root/.secrets && touch /root/.secrets/cloudflare.ini && touch /root/.secrets/netcup.ini

    read -n1 -p "Cloudflare API-Key?" key
    echo "dns_cloudflare_api_token = " $key | sudo tee /root/.secrets/cloudflare.ini > /dev/null

    chmod 400 /root/.secrets/cloudflare.ini
    chmod 400 /root/.secrets/netcup.ini

    certbot certonly \
    --dns-cloudflare \
    --dns-cloudflare-credentials /root/.secrets/cloudflare.ini \
    -d *.ck-srv.de  
;; 
n|N) echo no ;; 
  *) echo dont know ;; 
esac



