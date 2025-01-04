#!/bin/bash

HOSTNAME="samurai02"
USERNAME="vale"

hostnamectl set-hostname $HOSTNAME
echo "$(HOSTNAME).cybersamur.ai" >> /etc/hosts ### THIS DOESNT WORK

# Create Administrative User
useradd $USERNAME
usermod -aG sudo $USERNAME
usermod -s /bin/bash $USERNAME
mkdir /home/$USERNAME
chown $USERNAME:$USERNAME /home/$USERNAME

apt update -y
apt upgrade -y

# Install Core Packages
apt install net-tools git certbot -y

# Install Docker
curl -sSL https://get.docker.com/ | CHANNEL=stable bash
systemctl enable --now docker

# Install Pterodactyl Wings  ### THIS DOESNT WORK - WRONG ARCHITECTURE??
mkdir -p /etc/pterodactyl
curl -Lo /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")"
chmod u+x /usr/local/bin/wings

# Create Empty Wings Config File
touch /etc/pterodactyl/config.yml
echo "app_name: $(HOSTNAME)" >> /etc/pterodactyl/config.yml    ### $(HOSTNAME) DOESNT WORK 

# Set up SSL for HOSTNAME.cybersamur.ai
touch /root/certbot-setup.sh   ### $(HOSTNAME) DOESNT WORK 
cat >> /root/certbot-setup.sh << EOL
#!/bin/bash
certbot certonly -d $(HOSTNAME).cybersamur.ai --manual --preferred-challenges dns
systemctl restart wings
EOL
chown root:root /root/certbot-setup.sh
chmod 770 /root/certbot-setup.sh

echo "Please execute /root/certbot-setup.sh to finish TLS setup on the deployed host"

# Create Wings Daemon
touch /etc/systemd/system/wings.service
cat >> /etc/systemd/system/wings.service << EOL
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service
PartOf=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=4096
PIDFile=/var/run/wings/daemon.pid
ExecStart=/usr/local/bin/wings
Restart=on-failure
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOL

systemctl enable --now wings

# Configure Firewall
ufw allow from any to any proto tcp port 22 # Container SSH
ufw allow from any to any port 8443 # Wings Daemon
ufw allow from any to any port 2022 # Wings SFTP
