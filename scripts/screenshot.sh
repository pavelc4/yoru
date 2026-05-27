#!/usr/bin/env bash

# Yoru Screenshot Wrapper
# Dependencies: grim, slurp, wl-copy, tesseract, jq, curl

SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"

get_date() {
    date '+%Y-%m-%d_%H.%M.%S'
}

MODE=""
SAVE_FILE=0

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --mode) MODE="$2"; shift ;;
        --save) SAVE_FILE=1 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

if [[ -z "$MODE" ]]; then
    echo "Usage: $0 --mode [region|freeze|fullscreen|ocr|search]"
    exit 1
fi

case "$MODE" in
    region)
        # Select region and copy to clipboard + optionally save to file
        qs -c yoru ipc call drawers setScreenshotMode true
        if ! geom=$(slurp 2>/dev/null); then
            qs -c yoru ipc call drawers setScreenshotMode false
            exit 1
        fi
        qs -c yoru ipc call drawers setScreenshotMode false
        
        if [[ "$SAVE_FILE" -eq 1 ]]; then
            FILENAME="$SAVE_DIR/Screenshot_$(get_date).png"
            grim -g "$geom" "$FILENAME"
            wl-copy < "$FILENAME"
            notify-send "Screenshot Captured" "Saved to $FILENAME and clipboard" -i "$FILENAME" -a "Yoru Screenshot"
        else
            grim -g "$geom" - | wl-copy
            notify-send "Screenshot Captured" "Copied to clipboard" -a "Yoru Screenshot"
        fi
        ;;

    freeze)
        # Freeze screen and select region (standard grimshot/slurp behavior)
        qs -c yoru ipc call drawers setScreenshotMode true
        if ! geom=$(slurp 2>/dev/null); then
            qs -c yoru ipc call drawers setScreenshotMode false
            exit 1
        fi
        qs -c yoru ipc call drawers setScreenshotMode false
        
        grim -g "$geom" - | wl-copy
        notify-send "Screenshot Captured" "Copied region to clipboard" -a "Yoru Screenshot"
        ;;

    fullscreen)
        # Grab active workspace monitor or fallback to default grim
        MONITOR=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.monitor' 2>/dev/null)
        if [[ -z "$MONITOR" || "$MONITOR" == "null" ]]; then
            if [[ "$SAVE_FILE" -eq 1 ]]; then
                FILENAME="$SAVE_DIR/Screenshot_$(get_date).png"
                grim "$FILENAME"
                wl-copy < "$FILENAME"
                notify-send "Screenshot Captured" "Saved to $FILENAME and clipboard" -i "$FILENAME" -a "Yoru Screenshot"
            else
                grim - | wl-copy
                notify-send "Screenshot Captured" "Copied fullscreen to clipboard" -a "Yoru Screenshot"
            fi
        else
            if [[ "$SAVE_FILE" -eq 1 ]]; then
                FILENAME="$SAVE_DIR/Screenshot_$(get_date).png"
                grim -o "$MONITOR" "$FILENAME"
                wl-copy < "$FILENAME"
                notify-send "Screenshot Captured" "Saved to $FILENAME and clipboard" -i "$FILENAME" -a "Yoru Screenshot"
            else
                grim -o "$MONITOR" - | wl-copy
                notify-send "Screenshot Captured" "Copied fullscreen to clipboard" -a "Yoru Screenshot"
            fi
        fi
        ;;

    ocr)
        # Select region, run OCR (English) and copy text to clipboard
        qs -c yoru ipc call drawers setScreenshotMode true
        if ! geom=$(slurp 2>/dev/null); then
            qs -c yoru ipc call drawers setScreenshotMode false
            exit 1
        fi
        qs -c yoru ipc call drawers setScreenshotMode false
        
        TEMP_IMG="/tmp/ocr_image.png"
        grim -g "$geom" "$TEMP_IMG"
        
        # Run tesseract
        if command -v tesseract >/dev/null 2>&1; then
            tesseract "$TEMP_IMG" stdout -l eng 2>/dev/null | wl-copy
            TEXT=$(wl-paste)
            rm -f "$TEMP_IMG"
            if [[ -n "$TEXT" ]]; then
                notify-send "OCR Successful" "Copied recognized text to clipboard" -a "Yoru OCR"
            else
                notify-send "OCR Failed" "No text recognized" -u critical -a "Yoru OCR"
            fi
        else
            rm -f "$TEMP_IMG"
            notify-send "OCR Error" "tesseract is not installed" -u critical -a "Yoru OCR"
            exit 1
        fi
        ;;

    search)
        # Google Lens upload
        "$(dirname "$0")/snip_to_search.sh"
        ;;

    *)
        echo "Unknown mode: $MODE"
        exit 1
        ;;
esac
