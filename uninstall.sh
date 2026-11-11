#!/usr/bin/env bash
# Removes the Arasaka SDDM theme and restores any SDDM config lines the installer disabled.
set -euo pipefail

THEME="arasaka"
DEST="/usr/share/sddm/themes/$THEME"
DROPIN="/etc/sddm.conf.d/10-$THEME-theme.conf"

if [[ $EUID -ne 0 ]]; then
    exec sudo bash "${BASH_SOURCE[0]}"
fi

rm -rf "$DEST"
rm -f "$DROPIN"
echo "Removed $DEST and $DROPIN"

# Restore configs the installer backed up
for bak in /etc/sddm.conf.bak-"$THEME" /etc/sddm.conf.d/*.bak-"$THEME"; do
    [[ -f "$bak" ]] || continue
    orig="${bak%.bak-$THEME}"
    mv -f "$bak" "$orig"
    echo "Restored $orig"
done

echo "Done. SDDM will use whatever theme your restored config selects (or its default)."
