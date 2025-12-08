# Installing Plex on a Smart TV

This guide covers how to access your Plex server from various Smart TV platforms.

## Prerequisites

- Plex server running and accessible on your network (see main README.md)
- Smart TV connected to the same network as your Plex server
- Completed Plex server setup at http://localhost:32400/web

## Installation by TV Platform

### Samsung Smart TV (2016 or newer)

1. **Open Samsung App Store**
   - Press the **Home** button on your remote
   - Navigate to **Apps**

2. **Search for Plex**
   - Use the search function
   - Type "Plex"

3. **Install the App**
   - Select the Plex app
   - Click **Install**
   - Wait for installation to complete

4. **Sign In**
   - Open the Plex app
   - You'll see a 4-character code
   - On your computer/phone, go to **plex.tv/link**
   - Enter the code
   - Your libraries will appear automatically

---

### LG Smart TV (webOS)

1. **Open LG Content Store**
   - Press the **Home** button
   - Select **LG Content Store**

2. **Find Plex**
   - Go to **Apps & Games**
   - Search for "Plex"

3. **Install**
   - Select Plex
   - Click **Install**

4. **Link Your Account**
   - Launch Plex
   - Note the 4-digit code
   - Visit **plex.tv/link** on another device
   - Enter the code

---

### Sony Android TV

1. **Open Google Play Store**
   - Press **Home**
   - Select **Apps** → **Google Play Store**

2. **Search and Install**
   - Search for "Plex"
   - Select **Plex: Stream Movies & TV**
   - Click **Install**

3. **Sign In**
   - Open Plex
   - Get the link code
   - Go to **plex.tv/link**
   - Enter code

---

### Amazon Fire TV / Fire Stick

1. **Search for Plex**
   - From Home screen, select **Search**
   - Type "Plex"

2. **Download**
   - Select **Plex: Stream Free Movies & TV**
   - Click **Download** or **Get**

3. **Launch and Link**
   - Open Plex
   - Note the code
   - Visit **plex.tv/link**
   - Enter code

---

### Apple TV

1. **Open App Store**
   - From Apple TV home screen
   - Select **App Store**

2. **Search for Plex**
   - Use search
   - Find "Plex - Movies, TV, Music"

3. **Install**
   - Click **Get** or **Download**
   - Wait for installation

4. **Sign In**
   - Open Plex
   - Get activation code
   - Go to **plex.tv/link**
   - Enter code

---

### Roku TV / Roku Device

1. **Add Channel**
   - Press **Home**
   - Go to **Streaming Channels**
   - Search for "Plex"

2. **Install**
   - Select Plex
   - Click **Add Channel**

3. **Activate**
   - Open Plex channel
   - Get 4-character code
   - Visit **plex.tv/link**
   - Enter code

---

## Setting Up Server Connection

### If Your Server Doesn't Appear Automatically

1. **Manual Connection**
   - In the Plex TV app, go to Settings
   - Select "Server"
   - Choose "Add Server Manually"

2. **Enter Server Details**
   - **Server Address**: Your computer's local IP address
   - **Port**: 32400 (default)
   - Example: `192.168.1.100:32400`

3. **Find Your Server IP**
   - On your Plex server computer, run:
     ```bash
     # Linux/Mac
     hostname -I | awk '{print $1}'
     
     # Windows (PowerShell)
     (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"}).IPAddress
     ```

---

## Troubleshooting

### Can't Find Server

1. **Ensure both devices are on the same network**
   - TV and Plex server must be on same WiFi/LAN

2. **Check server is running**
   - Visit http://localhost:32400/web on the server computer

3. **Disable VPN temporarily** (if applicable)

4. **Enable Remote Access** (optional)
   - In Plex Web: Settings → Remote Access
   - Click "Enable Remote Access"
   - This allows access from anywhere

### Poor Streaming Quality

1. **Check network connection**
   - Use wired Ethernet if possible
   - Ensure strong WiFi signal

2. **Adjust streaming quality**
   - In Plex app: Settings → Quality
   - Try "Original" or "Maximum"
   - Lower if buffering occurs

3. **Ensure conversion is complete**
   - Files in `input/` folder must finish converting
   - Check converter logs: `docker-compose logs converter`

---

## Notes

- **No app available for your TV?** 
  - Use a streaming device (Fire Stick, Roku, Apple TV, Chromecast)
  - Cast from Plex mobile app to TV

- **4K/HDR Content**
  - Ensure TV supports format
  - Use high-speed HDMI cable
  - May require direct play (no transcoding)

- **First Time Setup**
  - You must complete Plex server setup on a computer first
  - Create account at plex.tv
  - Configure libraries before TV access

---

## Getting Help

- Check connection: `docker-compose logs plex`
- Check conversion: `docker-compose logs converter`
- Plex Support: https://support.plex.tv
