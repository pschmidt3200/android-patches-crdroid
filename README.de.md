# android-patches-crdroid

Eine strukturierte Sammlung modularer Patches, Framework-Verbesserungen und Hardware-Integrationen für **crDroid**.

Ziel dieses Repositories ist die Pflege sauberer, modularer Quellcode-Patches für crDroid — einschließlich hardwarespezifischer Anbindungen, wo ein Modul sie dokumentiert — ohne mitgelieferte proprietäre Hersteller-Binärdateien. Die Patches werden direkt in einen passenden crDroid-Quellbaum eingespielt.

**Derzeitiger ROM-Umfang: nur crDroid.** Jedes Modul nennt seinen crDroid-Branch und seine Referenzhardware. Unterstützung für andere ROMs ist nicht belegt.

**Aktueller Repo-Status: öffentlich; GitHub Actions aktiv.** Die Modulprüfungen laufen bei jedem Push. Kernelmodule behalten ihre Upstream-Lizenzbedingungen; vor Build oder Weitergabe die jeweilige `NOTICE` lesen.

---

## Verfügbare Module

Patches und Erweiterungen sind nach Themenbereichen in eigenständige Modulordner unterteilt:

### Hardware & Media Subsystems
* **[aptx-adaptive](aptx-adaptive/):** Hardware-Stack-Integration für Qualcomm FastConnect 7900 / SM8750 (aptX Adaptive, 44,1 kHz Lossless, Game-Audio Low-Latency-Modus). Referenzhardware: OnePlus 13 (`dodge`), OnePlus Pad 3 / Pad 2 Pro (`erhai`).

### User Interface & Preferences (Settings)
* **[donation-disable](donation-disable/):** Deaktivierung der Spendenaufforderungen und zugehörigen Menüeinträge in den crDroidSettings. Geltungsbereich: Universell (crDroid 16.0).

### System Services & Networking
* **[gps-servers](gps-servers/):** Konfiguration datenschutzfreundlicher Endpunkte für SUPL (Standortbestimmung) und NTP (Zeitsynchronisation). Geltungsbereich: Universell (crDroid 16.0).
* **[gms-fixes](gms-fixes/):** Anpassungen der Paket-Sichtbarkeit und Berechtigungsdeklarationen für Google-Dienste (GApps / MicroG). Geltungsbereich: Universell (crDroid 16.0 mit GApps).

### Kernel Subsystems
* **[bbrv3](bbrv3/):** Implementierung des Google BBRv3 TCP Congestion-Control-Algorithmus für Linux 6.6 Kernel.
* **[bbrv3-experimental](bbrv3-experimental/):** Experimentelles Update des TCP-Congestion-Control-Patches, nur zum Testen; ersetzt `bbrv3` in einem Testbuild.
* **[susfs-core](susfs-core/):** Korrekturen und Anpassungen für das SUSFS-Kerneltreibermodul. Geltungsbereich: Linux Kernel 6.6.

---

## Verwendung der Module

### Option 1: Fertiges Modul-Archiv herunterladen (Empfohlen)

Für einzelne Module muss nicht das gesamte Repository geklont werden:
1. Öffne die [Releases-Seite](https://github.com/pschmidt3200/android-patches-crdroid/releases) und lade das gewünschte Modul-Archiv `<modul>-<version>.zip` herunter (z. B. `aptx-adaptive-v1.2.zip`).
2. Entpacke das Archiv in das Hauptverzeichnis deines crDroid-Quellbaums.
3. Wechsle im Terminal in den entpackten Modulordner und führe das Skript aus:
   ```bash
   ./apply-patches.sh
   ```
   Das Skript prüft die Kompatibilität des Quellbaums automatisch und wendet alle Patches sauber an.

### Option 2: Über das vollständige Git-Repository

```bash
# Repository klonen
git clone https://github.com/pschmidt3200/android-patches-crdroid.git
cd android-patches-crdroid

# Zu einem bestimmten Release-Stand wechseln (z. B. v1.0)
git switch --detach v1.0

# Installer für das gewünschte Modul ausführen
cd <modul-ordner>
./apply-patches.sh
```

Alternativ können die Patches mit Standard-Git-Werkzeugen manuell eingespielt werden:
```bash
cd /pfad/zu/crdroid/source/<ziel-repository>
git apply /pfad/zu/android-patches-crdroid/<modul>/patches/<ziel_patch>.patch
```

---

## Wie die Module getrennt sind

Jedes Patch-Set ist ein **eigenständiger Modulordner**. Ein Modul hängt von keinem anderen ab, verweist nicht darauf und dokumentiert es nicht — außer seine eigene README sagt es ausdrücklich.

| Ort | Gehört zu | Inhalt |
|---|---|---|
| Repository-Wurzel | der ganzen Sammlung | Übersicht, Modulverzeichnis, Haftungsausschluss und Standard-`LICENSE` — **keine Patches** |
| `<modul>/` | genau einem Patch-Set | `README.md` + `README.de.md`, `NOTICE` (Upstream-Quellen und Referenz-Commits), `LICENSE`, `installer.json` und eigenständiges `apply-patches.sh` |
| `<modul>/patches/` | nur diesem Patch-Set | `.patch`-Dateien; jede beginnt mit einer Kopfzeile `# Target repository:`, die das Android-Zielrepository nennt |

**Kernregeln für jedes Modul:**
* **Ein Feature, ein Ordner** (`kebab-case`). Fremde Änderungen kommen nie in das `patches/` eines bestehenden Moduls.
* **Reine Quellcode-Diffs:** Patches sind Standard-Git-Diffs gegen die von crDroid genutzten Quellen und Build-Konfigurationen. Keine proprietären Blobs, Binärdateien oder Geräteschlüssel.
* **Dokumentation beschreibt nur das eigene Modul:** Voraussetzungen, crDroid-Branch, Referenz-Commits, getestete Geräte und bekannte Grenzen.
* **Support endet an der Modul-README:** Ein Modul ist nur insoweit getestet, wie seine README es belegt.
* **Skripte bleiben im Modul:** Sie berühren nur das modulseigene `patches/`-Verzeichnis.
* **Keine Versionsmischung:** Alle Patches eines Moduls immer aus demselben Commit bzw. Release-Archiv anwenden.

---

## Probleme melden

Wenn ein Patch nicht anwendbar ist, nicht baut oder sich auf dem Referenz-Setup fehlerhaft verhält, bitte ein [Issue über die Vorlage „Patch problem“ anlegen](https://github.com/pschmidt3200/android-patches-crdroid/issues/new?template=patch-problem.yml).

Bitte angeben:
* Modulname und Release-Tag (z. B. `aptx-adaptive-v1.2`) oder Commit-SHA.
* Die genaue Fehlermeldung oder den relevanten Log-Ausschnitt.
* Bluetooth-MAC-Adressen und Seriennummern vor dem Posten aus den Logs entfernen.

Rückmeldungen von anderen Geräten sind als Information willkommen. Bitte vorher den Haftungsausschluss unten beachten.

---

## Modul-Releases

Der [V1-Sammlungs-Release](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/v1.0) friert den vollständigen Quellpatch-Stand vom 01.10.2026 ein. Die enthaltenen Modulstände sind:

| Modul | Release-Tag |
|---|---|
| `aptx-adaptive` | `aptx-adaptive-v1.2` |
| `gms-fixes` | `gms-fixes-v1.0` |
| `gps-servers` | `gps-servers-v1.0` |
| `donation-disable` | `donation-disable-v1.0` |

Separate Kernel-Editionen (hinzugefügt ab 03.10.2026): `bbrv3-v1.0`, `bbrv3-v1.1`, `bbrv3-v1.2`, `bbrv3-experimental-v0.1` und `susfs-core-v1.0`. Sie sind nicht Teil des unveränderlichen Sammlungs-Snapshots `v1.0`. Jede Edition besitzt eigene Release-Notizen und ein separates Modul-ZIP.

---

## Kontinuierliche Integration & Automatische Tests

Alle Modularitätsregeln und Patch-Anwendbarkeiten werden bei jedem Push automatisch durch GitHub Actions geprüft:

* **Modularität und Format:** `.github/scripts/check-modules.sh` prüft Ordneraufbau, Patch-Köpfe und Konsistenz zwischen Skript, READMEs und `NOTICE`.
* **Test auf Wegwerf-Baum:** `.github/scripts/test-apply-script.sh` führt jedes `apply-patches.sh` auf einem isolierten Test-Quellbaum aus.
* **Link-Validierung:** `.github/scripts/test-markdown-links.sh` stellt sicher, dass alle lokalen Dokumentationslinks erreichbar sind.
* **Upstream-Referenzprüfung:** `.github/scripts/check-reference.sh` lädt die von Patches berührten Dateien frisch aus dem crDroid-Upstream, wendet die Patches an, nimmt sie zurück und prüft, ob das Repository sauber bleibt.
* **Installer-Generierung:** Die Installer-Logik wird zentral in `.github/installer/apply-patches.sh.in` gepflegt. Die Metadaten stammen aus `installer.json` des jeweiligen Moduls:
  ```bash
  python3 .github/scripts/generate-installers.py
  python3 .github/scripts/generate-installers.py --check
  ```

Für Maintainer vor einem Release:
```bash
MODULE=aptx-adaptive  # oder gms-fixes, gps-servers, donation-disable, bbrv3, bbrv3-experimental, susfs-core
python3 .github/scripts/generate-installers.py --check
bash .github/scripts/check-modules.sh
bash .github/scripts/test-apply-script.sh "$MODULE"
bash .github/scripts/check-reference.sh "$MODULE"
bash .github/scripts/check-reference.sh --branch 16.0 "$MODULE"
```

---

## Haftungsausschluss & Support-Hinweis

> [!IMPORTANT]
> **Privates Hobbyprojekt — Nutzung auf eigene Verantwortung:**
> * **Privater Charakter:** Dieses Repository wird in meiner Freizeit als persönliches Hobbyprojekt für Custom-ROM-Experimente gepflegt. Es ist **keine** kommerziell betreute Distribution und keine Plattform mit Vollzeit-Support.
> * **Keine universelle Geräteunterstützung:** Hardwaretests beschränken sich ausschließlich auf Geräte in meinem persönlichen Besitz (wie das Referenzgerät OnePlus 13). Für andere Hardware kann ich keine Tests durchführen oder Fehler beheben.
> * **Für erfahrene Anwender:** Diese Patches richten sich an Entwickler, ROM-Maintainer und erfahrene Nutzer, die mit dem Android-Build-System vertraut sind, Compilerfehler einordnen können und wissen, wie ein Gerät im Fehlerfall wiederhergestellt wird.
> * **Keine Gewährleistung:** Die Bereitstellung erfolgt ohne jegliche Gewährleistung („as is“). Die Verantwortung für Modifikationen am eigenen Gerät oder ROM-Build liegt vollständig beim Anwender.

---

## Lizenz

Soweit in den Modulordnern nicht anders angegeben, stehen Patches und Dokumentation unter der **Apache License, Version 2.0**. Siehe [LICENSE](LICENSE).

Kernel-Ausnahmen: `bbrv3` und `bbrv3-experimental` behalten die GPL-Bedingungen des Kernels, Dateihinweise und die `Dual BSD/GPL`-Deklaration des BBR-Kerns. `susfs-core` behält für sein Patch-Delta die Upstream-GPL Version 3. Dokumentation, Metadaten und Installer bleiben Apache 2.0. Die `LICENSE`- und `NOTICE`-Dateien in den Modulen regeln die Details.
