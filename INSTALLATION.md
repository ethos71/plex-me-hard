# Installation Guide - Run These Commands Manually

## You need to run these commands on your server to get Plex running:

### Step 1: Install Docker

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

**Then logout and login again** (or run `newgrp docker`)

### Step 2: Install Docker Compose

```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

Verify installation:
```bash
docker --version
docker-compose --version
```

### Step 3: Configure Google Drive (One-time)

```bash
cd /home/dominick/workspace/plex-me-hard
./setup.sh
```

Follow the prompts to:
- Authenticate with Google Drive
- Verify your "Kingdom of Heaven" file is visible

### Step 4: Start All Services

```bash
cd /home/dominick/workspace/plex-me-hard
docker-compose up -d
```

### Step 5: Check Status

```bash
cd /home/dominick/workspace/plex-me-hard
docker-compose ps
./check-status.sh
```

### Step 6: Access Plex

1. Get your server IP:
   ```bash
   hostname -I | awk '{print $1}'
   ```

2. Open in browser:
   - If on same machine: `http://localhost:32400/web`
   - If remote: `http://YOUR_IP:32400/web`

3. Login with:
   - Email: `dominick.do.campbell+1@gmail.com`
   - Password: `Cmsc101101!`

4. Add libraries:
   - Movies: `/data/movies`
   - TV Shows: `/data/tv`
   - Music: `/data/music`

### Step 7: Sync Your Movie

```bash
cd /home/dominick/workspace/plex-me-hard
./sync-now.sh
```

Watch conversion:
```bash
docker-compose logs -f converter
```

---

## Quick Reference

**Start services:**
```bash
docker-compose up -d
```

**Stop services:**
```bash
docker-compose down
```

**View logs:**
```bash
docker-compose logs -f
```

**Sync from Google Drive:**
```bash
./sync-now.sh
```

**Check movie status:**
```bash
./check-status.sh
```

**Troubleshoot Plex:**
```bash
./troubleshoot-plex.sh
```
