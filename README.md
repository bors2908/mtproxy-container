### Build

```bash
docker buildx build -t me.bors.mtproxy:latest --load .
```

### Run
```bash
docker run -d --name mtproxy -p 443:443 me.bors.mtproxy:latest
```
