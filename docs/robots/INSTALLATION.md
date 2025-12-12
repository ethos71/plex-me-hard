# Plex Installation Guide

## Server Setup

### Step 1: Install Plex Media Server

Download and install Plex from: https://www.plex.tv/media-server-downloads/

```bash
# For Ubuntu/Debian:
wget https://downloads.plex.tv/plex-media-server-new/1.41.3.9314-a0bfb8370/debian/plexmediaserver_1.41.3.9314-a0bfb8370_amd64.deb
sudo dpkg -i plexmediaserver_*.deb
sudo systemctl enable plexmediaserver
sudo systemctl start plexmediaserver
```

### Step 2: Initial Setup

1. Get your server IP:
   ```bash
   hostname -I | awk '{print $1}'
   ```

2. Open in browser: `http://YOUR_IP:32400/web`

3. Login with your Plex account:
   - Email: `dominick.do.campbell+1@gmail.com`
   - Password: `Cmsc101101!`

4. Complete the setup wizard

### Step 3: Add Media Libraries

1. In Plex web interface, click "Add Library"
2. Choose library type (Movies, TV Shows, Music)
3. Add folder: `/var/lib/plexmediaserver/Library/Movies`
4. Click "Add Library"

### Step 4: Enable Subtitles (Optional)

1. Settings → Agents → Movies
2. Enable "Local Media Assets" and "OpenSubtitles.org"
3. Settings → Languages
4. Select preferred subtitle language
5. Enable "Automatically select audio and subtitle tracks"

---

## Insignia Fire TV Setup

### Install Plex App

1. From Insignia TV home screen, navigate to **"Find"** or **"Search"**
2. Search for **"Plex"**
3. Select the Plex app from Amazon Appstore
4. Click **"Download"** or **"Get"**
5. Wait for installation to complete

### Sign In to Plex

1. Launch the Plex app
2. Select **"Sign In"**
3. You have two options:
   - **Option A:** Use the 4-digit PIN code shown on TV
     - Go to `plex.tv/link` on your phone/computer
     - Enter the 4-digit code
     - Sign in with your Plex account
   - **Option B:** Enter credentials directly on TV
     - Email: `dominick.do.campbell+1@gmail.com`
     - Password: `Cmsc101101!`

### Connect to Your Server

1. After signing in, Plex will automatically detect servers on your network
2. Select your server (e.g., "dominick-HP-ZBook-Firefly-15GZ")
3. If multiple servers appear, choose the one with your content
4. Your movies should now appear in the Movies library

### Troubleshooting

**Can't see your server?**
- Make sure TV and server are on the same network
- Restart Plex Media Server: `sudo systemctl restart plexmediaserver`
- Check firewall: `sudo ufw allow 32400/tcp`

**Library appears empty?**
- Scan library: Settings → Libraries → Movies → Scan Library Files
- Check file permissions: `sudo chmod -R 755 /var/lib/plexmediaserver/Library/Movies`
- Verify files exist: `ls -la /var/lib/plexmediaserver/Library/Movies`

**Multiple duplicate servers?**
- Sign out of Plex app on TV
- Restart Plex server
- Sign back into Plex app
