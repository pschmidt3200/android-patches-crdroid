# android-patches-crdroid

Eine strukturierte Sammlung modularer Quellcode-Patches, Framework-Erweiterungen und Hardware-Integrationen für **crDroid** (Android 16).

Alle Patches sind reine Quellcode-Diffs ohne proprietäre Binärdateien und können direkt in einen kompatiblen crDroid-Quellbaum eingespielt werden.

---

## Verfügbare Module

Jedes Modul ist in sich abgeschlossen und konzentriert sich auf eine spezifische Funktion:

### Hardware & Medien
* **[aptx-adaptive](aptx-adaptive/):** Bluetooth-Audio-Integration. Technische Details und Voraussetzungen im Modulordner.

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
Wähle das gewünschte Modul auf der [Releases-Seite](https://github.com/pschmidt3200/android-patches-crdroid/releases) aus und lade das `.zip`-Archiv herunter (z. B. `aptx-adaptive-v1.2.zip`).

### Schritt 2: In den crDroid-Quellbaum einspielen
1. Entpacke das heruntergeladene ZIP-Archiv in deinen crDroid-Quellordner.
2. Öffne ein Terminal im entpackten Ordner und führe den Installer aus:
   ```bash
   ./apply-patches.sh
   ```
Das Skript prüft automatisch die Kompatibilität deines Quellbaums und wendet die Patches sauber auf die jeweiligen Unter-Repositories an (`frameworks/base`, `packages/modules/Bluetooth`, etc.).

Nur auf Anwendbarkeit prüfen (ohne Änderungen zu schreiben):
```bash
./apply-patches.sh --check
```

Patches wieder rückgängig machen (Rollback):
```bash
./apply-patches.sh --reverse
```

*(Erfahrene Nutzer, die direkt mit Git arbeiten möchten, können dieses Repository klonen und `git apply` nutzen, wie in den einzelnen Modul-READMEs beschrieben).*

---

## Probleme melden

Falls ein Patch nicht sauber anwendbar ist oder Buildfehler auf crDroid 16.0 auftreten:
1. Bitte ein [Issue über die Vorlage „Patch problem“ anlegen](https://github.com/pschmidt3200/android-patches-crdroid/issues/new?template=patch-problem.yml).
2. Modulname, Gerätemodell und die Terminal-Fehlerausgabe beifügen.
3. *Bitte persönliche Daten (wie Bluetooth-MAC-Adressen oder Seriennummern) vor dem Absenden aus den Logs entfernen.*

---

## Hinweise & Haftungsausschluss

* **Privates Hobbyprojekt:** Dieses Repository wird in privater Freizeit gepflegt. Hardwaretests beschränken sich auf Geräte in meinem persönlichen Besitz (wie das OnePlus 13).
* **Zielgruppe:** Die Patches richten sich an ROM-Builder und erfahrene Android-Nutzer, die crDroid aus den Quellen kompilieren.
* **Nutzung auf eigene Verantwortung:** Änderungen am Quellcode und dem eigenen Gerät erfolgen ohne Gewährleistung („as is“).

---

## Lizenz

Soweit in den jeweiligen Modulen nicht anders angegeben, stehen Patches und Dokumentation unter der **Apache License 2.0**. Kernel-Patches behalten ihre Upstream-GPL-Lizenz. Siehe [LICENSE](LICENSE) und die jeweiligen `NOTICE`-Dateien für Details.
