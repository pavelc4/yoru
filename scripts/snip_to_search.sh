#!/usr/bin/env bash

# Yoru Snip to Search
# Capture a region, upload to uguu.se, and open in Google Lens

if ! geom=$(slurp 2>/dev/null); then
    exit 1
fi

TEMP_IMG="/tmp/search_image.png"
grim -g "$geom" "$TEMP_IMG"

if [[ -f "$TEMP_IMG" ]]; then
    notify-send "Uploading to Google Lens..." "Uploading snip to uguu.se..." -a "Yoru Lens"
    
    imageLink=$(curl -sF files[]=@"$TEMP_IMG" 'https://uguu.se/upload' | jq -r '.files[0].url' 2>/dev/null)
    
    if [[ -n "$imageLink" && "$imageLink" != "null" ]]; then
        xdg-open "https://lens.google.com/uploadbyurl?url=${imageLink}"
        notify-send "Google Lens Opened" "Search results should open in your browser" -a "Yoru Lens"
    else
        notify-send "Search Failed" "Failed to upload snip to uguu.se" -u critical -a "Yoru Lens"
    fi
    
    rm -f "$TEMP_IMG"
fi
