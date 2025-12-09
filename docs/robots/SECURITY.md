# Security Policy for Plex-Me-Hard

## CRITICAL: Media Files and Copyright

### Prohibited Actions

**NEVER commit the following to GitHub:**

1. **Media Files**
   - Movies (`.mp4`, `.mkv`, `.avi`, `.mov`, etc.)
   - TV Shows
   - Music files (`.mp3`, `.flac`, `.wav`, etc.)
   - Any downloaded content

2. **Torrent Files**
   - Downloaded torrents from `torrent/downloads/`
   - `.torrent` files from `torrent/watch/`
   - Any content in `torrent/config/`

3. **Associated Files**
   - Subtitle files for downloaded content
   - Media metadata
   - Any files in `data/`, `input/`, or `torrent/` directories

### Why This Matters

- **Copyright Infringement**: Downloaded media is copyrighted
- **Legal Risk**: Distributing copyrighted content is illegal
- **DMCA Takedowns**: GitHub will remove repositories with copyrighted content
- **Account Suspension**: Violations can result in account termination
- **Terms of Service**: Violates GitHub's Acceptable Use Policies

### Protection Mechanisms

The `.gitignore` file protects against accidental commits:

```gitignore
# Data directories - Contains downloaded media files
input/
data/
config/
transcode/

# Torrent directories - NEVER commit these to git
torrent/downloads/
torrent/config/
torrent/watch/

# All media file types - NEVER commit to git
*.mp4
*.mkv
*.avi
... (all media extensions)
```

### What IS Safe to Commit

✅ **Allowed:**
- Configuration files (`.yml`, `.json`)
- Scripts (`.sh`, `.py`)
- Documentation (`.md`)
- `torrent/magnet-links.md` (contains only magnet links, not files)
- Agent and prompt definitions
- Empty directory structures

❌ **Forbidden:**
- Any actual media files
- Downloaded torrent content
- Subtitles for downloaded content
- Anything in ignored directories

### Developer Guidelines

1. **Always check before committing:**
   ```bash
   git status
   git diff --staged
   ```

2. **NEVER use force-add:**
   ```bash
   # NEVER DO THIS:
   git add -f data/movies/movie.mp4
   ```

3. **Verify .gitignore is working:**
   ```bash
   git check-ignore data/movies/*.mp4
   # Should return file paths (means they're ignored)
   ```

4. **If media files appear in git status:**
   - DO NOT commit them
   - Check if `.gitignore` is correct
   - Use `git restore --staged <file>` to unstage

### AI Agent Instructions

If an AI agent or user requests committing media files:

1. **REFUSE** politely but firmly
2. **EXPLAIN** the copyright and legal risks
3. **REMIND** that `.gitignore` protects automatically
4. **SUGGEST** only committing allowed files

### Incident Response

If media files are accidentally committed:

1. **Immediately** remove the commit:
   ```bash
   git reset HEAD~1
   git push --force
   ```

2. **Clear Git history** if needed:
   ```bash
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch path/to/file" \
     --prune-empty --tag-name-filter cat -- --all
   ```

3. **Contact GitHub** if DMCA notice received

### Questions?

- Check `.gitignore` for protected paths
- Review this security policy
- When in doubt, DON'T commit

---

**Remember: Configuration and code = OK. Media files = NEVER.**
