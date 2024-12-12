# 🚀 **Ubuntu Server Wayland Kiosk Setup**    

Ein **Bash-Skript**, das **Ubuntu Server** in einen **Chromium-Kiosk** mit **Sway (Wayland)** verwandelt. Ideal zur Anzeige eines **Home Assistant Dashboards** oder anderer Webanwendungen im Vollbildmodus auf einem **Touchscreen-Monitor**.

---

## ⚙️ **Funktionen**  
- 📦 **Automatische Installation:** Snapd, Sway und Chromium (Snap)  
- 👤 **Benutzerverwaltung:** Erstellt den Benutzer `kiosk` mit automatischem Login  
- 🖥️ **Vollbildmodus:** Chromium im Kiosk-Modus mit benutzerdefinierter URL  
- ✋ **Touchscreen-Support:** Bildschirmrotation und Touch-Eingabe-Unterstützung  
- ⌨️ **Tastaturlayout:** Deutsches Tastaturlayout (anpassbar)  

---

## 📦 **Installation**   

Das Skript kann direkt mit folgendem Befehl ausgeführt werden:  

```bash
bash -c "$(wget -qLO - https://raw.githubusercontent.com/exnerit/ubuntu-server-wayland-kiosk/main/install-kiosk.sh)"
```

## 🔧 **Konfiguration bearbeiten**
Die Sway-Konfiguration kann nach der Installation durch folgenden Befehl angepasst werden:

```bash
sudo -u kiosk nano /home/kiosk/.config/sway/config
```

## **Disclaimer**  

Die Nutzung dieses Skripts erfolgt auf **eigene Verantwortung**. Der Autor übernimmt **keine Haftung** für **Schäden, Datenverluste** oder **Systemprobleme**, die durch die Installation oder Verwendung entstehen könnten.  

Vor der Ausführung wird empfohlen, wichtige Daten zu sichern und die Konfiguration an individuelle Anforderungen anzupassen.