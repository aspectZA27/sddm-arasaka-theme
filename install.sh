#!/usr/bin/env bash
# Installer for the Arasaka SDDM theme.
#
# Usage:
#   ./install.sh                 install and activate the theme
#   ./install.sh --no-activate   install only (don't touch SDDM config)
#   ./install.sh --logo FILE     also install FILE as the main logo
#                                (AVIF/WebP/JPG are converted to PNG if ImageMagick is available)
set -euo pipefail

THEME="arasaka"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$HERE/$THEME"
DEST="/usr/share/sddm/themes/$THEME"
DROPIN_DIR="/etc/sddm.conf.d"
DROPIN="$DROPIN_DIR/10-$THEME-theme.conf"

ACTIVATE=1
LOGO=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-activate) ACTIVATE=0 ;;
        --logo)
            LOGO="${2:-}"
            [[ -n "$LOGO" ]] || { echo "--logo needs a file path" >&2; exit 1; }
            LOGO="$(readlink -f "$LOGO")"
            shift
            ;;
        -h|--help) sed -n '2,9p' "${BASH_SOURCE[0]}"; exit 0 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
    shift
done

if [[ ! -d "$SRC" ]]; then
    echo "Can't find the '$THEME' folder next to this script." >&2
    exit 1
fi

if [[ -n "$LOGO" && ! -f "$LOGO" ]]; then
    echo "Logo file not found: $LOGO" >&2
    exit 1
fi

# Re-run as root (readlink above already made the logo path absolute)
if [[ $EUID -ne 0 ]]; then
    echo "Needs root to write to /usr/share and /etc, asking for sudo..."
    args=()
    (( ACTIVATE )) || args+=(--no-activate)
    [[ -n "$LOGO" ]] && args+=(--logo "$LOGO")
    exec sudo bash "${BASH_SOURCE[0]}" "${args[@]}"
fi

# Keep any logos the user already installed across re-installs
KEEP="$(mktemp -d)"
trap 'rm -rf "$KEEP"' EXIT
if [[ -d "$DEST/assets" ]]; then
    cp -a "$DEST/assets/." "$KEEP/" 2>/dev/null || true
fi

echo "Installing theme to $DEST"
rm -rf "$DEST"
mkdir -p "$DEST"
cp -r "$SRC/." "$DEST/"
cp -a "$KEEP/." "$DEST/assets/" 2>/dev/null || true
find "$DEST" -type d -exec chmod 755 {} +
find "$DEST" -type f -exec chmod 644 {} +

# Optional logo
if [[ -n "$LOGO" ]]; then
    kind="$(file -b "$LOGO")"
    if [[ "$kind" == PNG* ]]; then
        install -m 644 "$LOGO" "$DEST/assets/logo.png"
    elif command -v magick >/dev/null 2>&1; then
        magick "$LOGO" "$DEST/assets/logo.png"
        chmod 644 "$DEST/assets/logo.png"
    elif command -v convert >/dev/null 2>&1; then
        convert "$LOGO" "$DEST/assets/logo.png"
        chmod 644 "$DEST/assets/logo.png"
    else
        echo "Logo is not a PNG ($kind) and ImageMagick isn't installed." >&2
        echo "Install it (sudo pacman -S imagemagick libheif libavif) or convert the file yourself." >&2
    fi
fi

# Warn about logos that Qt can't load (for example an AVIF saved as .png)
for f in "$DEST/assets/logo.png" "$DEST/assets/logo-small.png"; do
    if [[ -f "$f" ]] && ! file -b "$f" | grep -qE '^(PNG|JPEG|GIF|SVG|Web/P)'; then
        echo "Warning: $(basename "$f") is '$(file -b "$f")', which SDDM can't load. Convert it to a real PNG."
    fi
done

if (( ! ACTIVATE )); then
    echo "Installed. Skipped activation (--no-activate)."
    exit 0
fi

# Make this the only theme setting. SDDM reads /etc/sddm.conf last, so a leftover
# Current= line there (or in another drop-in) would silently override ours.
mkdir -p "$DROPIN_DIR"
for f in /etc/sddm.conf "$DROPIN_DIR"/*.conf; do
    [[ -f "$f" && "$f" != "$DROPIN" ]] || continue
    if grep -qE '^[[:space:]]*Current=' "$f"; then
        [[ -e "$f.bak-$THEME" ]] || cp -a "$f" "$f.bak-$THEME"
        sed -i -E 's/^([[:space:]]*)Current=/\1#Current=/' "$f"
        echo "Disabled the old theme line in $f (backup: $f.bak-$THEME)"
    fi
done

printf '[Theme]\nCurrent=%s\n' "$THEME" > "$DROPIN"
echo "Wrote $DROPIN"

cat <<EOF

Done. Preview it without logging out:
  sddm-greeter-qt6 --test-mode --theme $DEST

It will show on your next login screen (or after: sudo systemctl restart sddm).
Add your own logo with:  ./install.sh --logo /path/to/logo.png
EOF
