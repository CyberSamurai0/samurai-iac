# Cloud-Init Template
Used to enhance the deployment of Pterodactyl Wings nodes for my own personal topology

### Example Usage
```yaml
#include
https://raw.githubusercontent.com/CyberSamurai0/cloud-init/refs/heads/main/samurai-instance.sh
```

## Post-Install
Some additional configuration is required.
### Enable Administrative Account Login
Either password or SSH-key authentication can be used.
### Issue Let's Encrypt Certificate for Host
```bash
# This will require interaction with your DNS server
./root/certbot-setup.sh
```
