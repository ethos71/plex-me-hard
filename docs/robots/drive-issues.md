# External Drive Issues

## Current Status
- Drive: /dev/sda1 - TOSHIBA MQ01ABD1 (1TB)
- Usage: 202G/916G (23% full)
- Mount: /media/dominick/TOSHIBA MQ01ABD1

## Known Issues

### Corrupted Directory
- **Location**: `/media/dominick/TOSHIBA MQ01ABD1/steamapps`
- **Error**: Input/output error
- **Cause**: Filesystem corruption or bad sectors
- **Status**: Cannot be removed due to I/O errors

### Workaround
The corrupted steamapps folder cannot be deleted but doesn't affect plex-me-hard operations. It can be ignored for now.

### Warning Signs
This I/O error could be an early indicator of the drive failure issue you mentioned (drive fails after 50% full). Current status is only 23% full, so we have space, but we should monitor closely.

## Recommendations
1. Monitor drive health with SMART tools: `sudo smartctl -a /dev/sda1`
2. Set up alerts when drive reaches 45% capacity
3. Have backup/migration plan ready
4. Consider replacing drive if more I/O errors appear

## Date
2025-12-10
