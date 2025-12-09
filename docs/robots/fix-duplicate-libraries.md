# Fix Duplicate Movie Libraries in Plex

## Problem
When setting up Plex on a new TV, you see duplicate "Movies" entries in the library list.

## Root Cause
Multiple movie libraries were created in Plex pointing to the same or different directories:
- One library might point to `/data/movies`
- Another might point to an old path
- Plex's built-in "Movies & Shows" (free content) appears separately

## Solution

### Step 1: Identify Duplicate Libraries

1. **Open Plex Web UI:**
   - Navigate to: http://192.168.12.143:32400/web
   - Or: http://localhost:32400/web

2. **Go to Settings:**
   - Click the wrench icon (⚙️) in top right
   - Select **"Manage"** → **"Libraries"**

3. **Check existing libraries:**
   - You should see your libraries listed
   - Look for multiple "Movies" entries
   - Note which ones point to `/data/movies`

### Step 2: Remove Duplicate Libraries

1. **For each duplicate library:**
   - Hover over the library name
   - Click the **trash icon** (🗑️) or **three dots menu**
   - Select **"Delete"**
   - Confirm deletion

2. **Keep only ONE Movies library:**
   - Should point to: `/data/movies`
   - Name it clearly: "My Movies" or "Personal Movies"

### Step 3: Create Clean Library (If Needed)

If you deleted all libraries by accident:

1. **Add Library:**
   - Click **"+ Add Library"** button
   - Select **"Movies"**
   - Name: **"Movies"** or **"My Movies"**
   - Click **"Next"**

2. **Add Folder:**
   - Click **"Browse for Media Folder"**
   - Navigate to: `/data/movies`
   - Click **"Add"**
   - Click **"Add Library"**

3. **Configure Settings:**
   - Agent: **Plex Movie** (recommended)
   - Language: **English**
   - Enable: **"Store artwork with media"**
   - Enable: **"Include adult content"** (if desired)

### Step 4: Separate Plex Free Content

Plex's free content (Movies & Shows) is SEPARATE and cannot be deleted:
- This is **normal** and **expected**
- It appears as **"Movies & Shows"** (not "Movies")
- Your personal library will be separate

### Expected Result

After cleanup, you should see:
- ✅ **Movies** (or "My Movies") - Your personal library from `/data/movies`
- ✅ **Movies & Shows** - Plex's free content (built-in)
- ✅ **TV Shows** (if configured) - From `/data/tv`
- ✅ **Music** (if configured) - From `/data/music`

## Prevention

To avoid duplicates in the future:

1. **Don't create multiple libraries for the same content type**
2. **Use clear, distinct names:**
   - "My Movies" for personal content
   - "Family Movies" if you have a second source
3. **Document your library structure** (see below)

## Current Library Structure

```
Recommended Setup:
├── Movies (Personal)     → /data/movies     (Your torrents)
├── TV Shows (Personal)   → /data/tv         (Future TV shows)
├── Music (Personal)      → /data/music      (Future music)
└── Movies & Shows (Plex) → Built-in         (Free content)
```

## Quick Fix Command Line (Advanced)

If you can't access the web UI, you can query libraries via API:

```bash
# Get Plex token
PLEX_TOKEN=$(sudo grep -oP 'PlexOnlineToken="\K[^"]+' /var/lib/plexmediaserver/Library/Application\ Support/Plex\ Media\ Server/Preferences.xml 2>/dev/null)

# List all libraries
curl -s "http://localhost:32400/library/sections?X-Plex-Token=$PLEX_TOKEN" | grep -oP 'title="[^"]+"|key="[^"]+"'

# Delete a library (replace LIBRARY_ID with actual ID)
curl -X DELETE "http://localhost:32400/library/sections/LIBRARY_ID?X-Plex-Token=$PLEX_TOKEN"
```

## Troubleshooting

### Problem: Can't delete a library
**Solution:** Make sure Plex is running and you're logged in with admin account

### Problem: Library deleted but still shows on TV
**Solution:** Sign out and sign back in on the Samsung TV app

### Problem: Movies disappeared after deleting library
**Solution:** Files are still in `/data/movies` - just re-add the library

### Problem: Multiple "Movies & Shows" entries
**Solution:** This shouldn't happen - "Movies & Shows" is Plex's free content and appears once. If you see duplicates of YOUR library, delete the extras.

## Verification

After fixing:

1. **Check web interface:** Should show clean library list
2. **Check Samsung TV:** 
   - Sign out of Plex app
   - Sign back in
   - Should now show deduplicated libraries
3. **Scan library:** Settings → Libraries → [Your Movies] → "Scan Library Files"

---

**Last Updated:** 2025-12-09
**@plex-me-hard Agent**
