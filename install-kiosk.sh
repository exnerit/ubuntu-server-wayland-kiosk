#!/bin/bash

# Ubuntu Server Wayland Kiosk Setup

# Abbruch bei Fehler
set -e

# URL-Abfrage mit Eingabeprüfung
while true; do
    read -rp "URL für den Kiosk-Modus eingeben (muss mit http:// oder https:// beginnen): " KIOSK_URL
    
    # Prüfung auf gültiges URL-Format
    if [[ $KIOSK_URL =~ ^https?:// ]]; then
        echo "Verwende URL: $KIOSK_URL"
        break
    else
        echo "Ungültige URL! Eine gültige URL muss mit http:// oder https:// beginnen."
    fi
done


echo "Verwende URL: $KIOSK_URL"

echo "### System aktualisieren und erforderliche Pakete installieren..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y snapd sway

echo "### Chromium (Snap) installieren..."
sudo snap install chromium

echo "### Kiosk-Benutzer erstellen..."
if ! id "kiosk" &>/dev/null; then
    sudo adduser --disabled-password --gecos "" kiosk
else
    echo "Benutzer 'kiosk' existiert bereits, überspringe..."
fi

echo "### Automatischen Login konfigurieren..."
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin kiosk --noclear %I \$TERM
Type=idle
EOF

echo "### Sway-Konfiguration einrichten..."
sudo -u kiosk mkdir -p /home/kiosk/.config/sway
sudo tee /home/kiosk/.config/sway/config > /dev/null << EOF
# Sway-Konfigurationsdatei für den Kiosk-Modus
# Diese Datei steuert die Anzeigeeinstellungen und den Start des Chromium-Kiosks.

# **1. Bildschirm-Ausgabe einstellen wenn nicht autoamtisch erkannt wird**
# Standardausgabe ist DP-1. Falls ein anderer Monitor verwendet wird,
# "DP-1" durch den passenden Wert ersetzen.
# z.B. HDMI-A-1 oder HDMI-A-2
#set \$display "DP-1"

# **2. Bildschirm-Ausrichtung**
# Definiert die Ausrichtung des Displays:
# Mögliche Werte: "normal" (Standard), "90", "180", "270".
# Für gespiegelte Ausgaben: "flipped", "flipped-90", "flipped-180", "flipped-270".
#output \$display {
#    transform normal
#}

# **3. Touchscreen-Eingabe binden wenn nicht automatisch erkannt wird**
# Weist die Touch-Eingabe der aktuellen Bildschirmausgabe zu.
# Falls ein Touchscreen nicht funktioniert, kann dieser Abschnitt angepasst werden.
#input type:touch {
#   map_to_output \$display
#}

# **4. Mauszeiger-Einstellungen**
# Blendet den Mauszeiger nach 0 Sekunden aus (sofort).
# Wert ändern, um den Cursor länger sichtbar zu lassen.
seat * {
    hide_cursor 0
}

# **5. Tastaturlayout**
# Standardmäßig wird das deutsche Tastaturlayout verwendet.
# "de" durch "us", "fr" oder ein anderes unterstütztes Layout ersetzen.
input * {
    xkb_layout de
}

# **6. Chromium im Kiosk-Modus starten**
# Chromium wird mit folgenden Einstellungen gestartet:
# - Vollbildmodus (Kiosk)
# - Keine Fehlermeldungen
# - Keine Infoleisten
# - URL im App-Modus ohne Navigationsleiste
# URL durch Bearbeiten des Werts nach --app= anpassen.

# **Erklärung der Chromium-Optionen für Wayland-Unterstützung:**
# --enable-features=UseOzonePlatform
# Aktiviert die Ozone-Plattform-Unterstützung in Chromium.
# Ozone ist eine Abstraktionsschicht für verschiedene Grafikplattformen
# wie X11 und Wayland und ermöglicht die Nutzung moderner Grafik-APIs.

# --ozone-platform=wayland
# Weist Chromium an, Wayland direkt als Anzeigeprotokoll zu verwenden.
# Dies sorgt für native Unterstützung von Touchscreens und reduziert
# die Abhängigkeit von X11. Diese Option ist zwingend erforderlich,
# da Sway nur mit Wayland funktioniert.
exec_always chromium \\
    --kiosk \\
    --noerrdialogs \\
    --no-first-run \\
    --disable-features=TranslateUI \\
    --app="$KIOSK_URL" \\
    --enable-features=UseOzonePlatform \\
    --ozone-platform=wayland \\
    --disable-gpu
EOF

echo "### Automatischen Start von Sway konfigurieren..."
sudo tee -a /home/kiosk/.profile > /dev/null << EOF

# Sway automatisch starten
if [ -z "\$DISPLAY" ] && [ "\$(tty)" = "/dev/tty1" ]; then
    exec sway
fi
EOF

echo "### Berechtigungen anpassen..."
sudo chown -R kiosk:kiosk /home/kiosk/.config
sudo chmod -R 700 /home/kiosk/.config

echo "### Einrichtung abgeschlossen. System wird neu gestartet..."
sudo reboot
