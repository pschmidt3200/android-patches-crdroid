# android-patches-crdroid

Eine strukturierte Sammlung modularer Quellcode-Patches, Framework-Erweiterungen und Hardware-Integrationen für **crDroid 16.0 (Android 16)**.

Alle funktionalen Änderungen werden als Quellcode-Patches ohne proprietäre Binärdateien bereitgestellt und können direkt in einen kompatiblen crDroid-Quellbaum eingespielt werden.

---

## Verfügbare Module

Jedes Modul ist in sich abgeschlossen und konzentriert sich auf eine spezifische Funktion:

### Hardware & Medien
* **[aptx-adaptive](aptx-adaptive/):** Bluetooth-Audio-Integration. Technische Details und Voraussetzungen im Modulordner.
* **[gaming-charge-bypass](gaming-charge-bypass/):** Das Laden pausiert, solange ein Spiel läuft, und der vorherige Ladezustand wird bei Spielende wiederhergestellt; die Schwelle ist im GameSpace-Panel einstellbar. Technische Details und die Grenzen der Geräteprüfung im Modulverzeichnis.
* **[le-audio-fixes](le-audio-fixes/):** LE-Audio-Korrekturen: Empfänger, die die gesammelte Attributabfrage des Stacks nie beantworten, können verbinden, eine gewählte Abtastrate oder Frame-Dauer kommt im Stream an, und 32 kHz sowie 24 kHz / 7,5 ms stehen für Medien bereit. Technische Details und Voraussetzungen im Modulordner.
* **[oplus-hardware-fixes](oplus-hardware-fixes/):** Die LTPO-Einstellung zeigt die tatsächliche Panel-Konfiguration statt der letzten gespeicherten Auswahl, und die Touch-HAL prüft Treiber- und Binder-Antworten statt Erfolg anzunehmen. Technische Details im Modulordner.

### Benutzeroberfläche & Einstellungen
* **[bluetooth-codec-ui](bluetooth-codec-ui/):** Bluetooth-Audio-Codec-Auswahlmenü und Statusanzeige in den Einstellungen. Technische Details im Modulordner.
* **[donation-disable](donation-disable/):** Bereinigung von Spendenhinweisen in den Einstellungen. Technische Details im Modulordner.

### Systemdienste & Netzwerk
* **[gps-servers](gps-servers/):** Alternative SUPL- und NTP-Serverkonfiguration. Technische Details im Modulordner.
* **[gms-fixes](gms-fixes/):** Kompatibilitätsanpassungen für Google-Dienste. Technische Details im Modulordner.

### Kernel-Subsysteme
* **[bbrv3](bbrv3/):** TCP-Congestion-Control-Patch. Technische Details im Modulordner.
* **[bbrv3-experimental](bbrv3-experimental/):** Experimentelles Update des TCP-Congestion-Control-Patches, nur zum Testen; ersetzt `bbrv3` in einem Testbuild. Technische Details im Modulordner.
* **[susfs-core](susfs-core/):** Kernel-Patch-Korrekturen. Technische Details im Modulordner.

---

## Installation & Verwendung

### Schritt 1: Modul herunterladen
Wähle das gewünschte Modul auf der [Releases-Seite](https://github.com/pschmidt3200/android-patches-crdroid/releases) aus und lade das `.zip`-Archiv herunter (z. B. `bluetooth-codec-ui-v1.2.zip` oder `aptx-adaptive-v1.4.zip`).

### Schritt 2: In den crDroid-Quellbaum einspielen
1. Entpacke das heruntergeladene ZIP-Archiv an einem beliebigen Ort außerhalb oder neben deinem crDroid-Quellordner.
2. Öffne ein Terminal im entpackten Ordner und führe den Installer aus:
   ```bash
   # 1. Zuerst Kompatibilität prüfen (Simulation ohne Dateien zu verändern):
   ./apply-patches.sh --check /pfad/zu/crdroid

   # 2. Patches einspielen:
   ./apply-patches.sh /pfad/zu/crdroid

   # 3. (Optional) Patches bei Bedarf wieder rückgängig machen (Rollback):
   ./apply-patches.sh --reverse /pfad/zu/crdroid
   ```

Das Skript prüft automatisch die Kompatibilität des Quellbaums und wendet die Patches sauber auf die vom jeweiligen Modul definierten Ziel-Repositories an.

*(Erfahrene Nutzer, die direkt mit Git arbeiten möchten, können dieses Repository klonen und `git apply` nutzen, wie in den einzelnen Modul-READMEs beschrieben).*

---

## Probleme melden

Falls ein Patch nicht sauber anwendbar ist oder Buildfehler auf crDroid 16.0 auftreten:
1. Bitte ein [Issue über die Vorlage „Patch problem“ anlegen](https://github.com/pschmidt3200/android-patches-crdroid/issues/new?template=patch-problem.yml).
2. Modulname, Release-Tag oder Repository-Commit, Gerätemodell und die Terminal-Fehlerausgabe beifügen.
3. *Bitte persönliche Daten (wie Bluetooth-MAC-Adressen oder Seriennummern) vor dem Absenden aus den Logs entfernen.*

---

## Hinweise & Haftungsausschluss

* **Privates Hobbyprojekt:** Dieses Repository wird in persönlicher Freizeit gepflegt. Hardwaretests beschränken sich auf eigene Referenzgeräte (wie das OnePlus 13).
* **Support:** Antworten auf Issues, Updates und Tests erfolgen nach Verfügbarkeit von persönlicher Freizeit und Hardware.
* **Zielgruppe:** Die Patches richten sich an ROM-Builder und erfahrene Android-Nutzer, die crDroid aus den Quellen kompilieren.
* **Keine proprietären Binärdateien:** Das Repository enthält ausschließlich Open-Source-Patches. Es werden keine proprietären Hersteller-Blobs, Firmware-Dateien oder lizenzierten Codec-Binaries verteilt.
* **Umkehrbar:** Alle Module unterstützen das Zurücknehmen (`--reverse`) auf einem kompatiblen, ansonsten unveränderten Quellbaum. Spätere Konflikte durch lokale Änderungen müssen manuell aufgelöst werden.
* **Nutzung auf eigene Verantwortung:** Änderungen am Quellcode und dem eigenen Gerät erfolgen ohne Gewährleistung („as is“).

---

## Lizenz

Soweit in den jeweiligen Modulen nicht anders angegeben, stehen Patches und Dokumentation unter der **Apache License 2.0**. Kernel-Patches behalten ihre Upstream-GPL-Lizenz. Siehe [LICENSE](LICENSE) und die jeweiligen `NOTICE`-Dateien für Details.
