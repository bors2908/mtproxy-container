### Build and run

```bash
# Prepare
mkdir -p ~/mtproxy
cd ~/mtproxy

# Download
curl -O https://raw.githubusercontent.com/bors2908/mtproxy-container/main/Dockerfile

# Build
docker buildx build -t me.bors.mtproxy:latest --load .

# Run
docker run -d --name mtproxy -p 443:443 me.bors.mtproxy:latest

# Get generated secret
docker exec mtproxy cat /etc/mtproto-proxy/mt_secret
```
