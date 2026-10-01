# android-patches-crdroid

Eine strukturierte Sammlung modularer Patches, Framework-Verbesserungen und Hardware-Integrationen für **crDroid** und AOSP-basierte Custom ROMs.

Ziel dieses Repositories ist die Pflege sauberer, herstellerneutraler Quellcode-Patches, die direkt in den Build-Tree eingespielt oder über Local Manifests eingebunden werden können.

---

## Struktur des Repositories

Patches und Erweiterungen sind nach Themenbereichen in eigenständige Ordner unterteilt:

```text
android-patches-crdroid/
├── README.md                  # Allgemeine Übersicht und Anleitung (EN)
├── README.de.md               # Deutsche Dokumentation
├── LICENSE                    # Lizenz (Apache 2.0)
├── .github/                   # Issue-Formular und CI-Prüfungen (workflows/, scripts/)
│
├── aptx-adaptive/             # aptX Adaptive DSP-Offload & Bluetooth-Anbindung
│   ├── README.md              # Modul-Dokumentation & Voraussetzungen (EN)
│   ├── README.de.md           # Deutsche Modul-Dokumentation
│   ├── apply-patches.sh       # Automatisches Installations- & Prüfskript
│   ├── NOTICE                 # Herkunftsnachweise, Referenz-Commits & Lizenzen
│   ├── LICENSE                # Modul-Lizenz (Apache 2.0)
│   └── patches/               # Git-Patches (Bluetooth, Frameworks, Settings, GameSpace, Device)
│
└── [weitere-module]/          # Künftige Patch-Kategorien (Kernel, System etc.)
```

---

## Wie die Module getrennt sind

Jedes Patch-Set ist ein **eigenständiger Modulordner**. Ein Modul hängt von keinem anderen ab,
verweist nicht darauf und dokumentiert es nicht — außer seine eigene README sagt es ausdrücklich.

| Ort | Gehört zu | Inhalt |
|---|---|---|
| Repository-Wurzel | der ganzen Sammlung | diese Übersicht, das Modulverzeichnis, der Haftungsausschluss und die Standard-`LICENSE` — **keine Patches** |
| `<modul>/` | genau einem Patch-Set | `README.md` + `README.de.md`, `NOTICE` (Upstream-Quellen und Referenz-Commits), `LICENSE`, optional `apply-patches.sh` |
| `<modul>/patches/` | nur diesem Patch-Set | `.patch`-Dateien; jede beginnt mit einer Kopfzeile `# Target repository:`, die das Android-Zielrepository nennt |

Regeln für jedes Modul:

* **Ein Feature, ein Ordner** (`kebab-case`). Fremde Änderungen kommen nie in das `patches/` eines bestehenden Moduls.
* **Die Doku beschreibt nur das eigene Modul:** Voraussetzungen, crDroid-Branch, Referenz-Commits, getestete Geräte und bekannte Grenzen.
* **Der Support endet dort, wo die Modul-README endet.** Ein Modul ist nur so weit getestet, wie seine README es sagt.
* **Skripte bleiben im eigenen Modul** und fassen nur dessen `patches/`-Ordner an.
* **Fassungen werden nicht gemischt:** alle Patches eines Moduls aus demselben Commit dieses Repositories anwenden.
* **Die Liste *Verfügbare Module* unten ist die einzige Stelle, an der Module miteinander verlinkt werden.**

Diese Regeln werden bei jedem Push automatisch geprüft: `.github/scripts/check-modules.sh` prüft
Aufbau, Patch-Kopfzeilen und -Format sowie, ob Skript, READMEs und `NOTICE` dieselben Patches nennen;
`.github/scripts/test-apply-script.sh` lässt das `apply-patches.sh` jedes Moduls gegen einen
Wegwerf-Baum laufen. Beide lassen sich lokal aus der Repository-Wurzel starten.

---

## Richtlinien & Standards

* **Modular & getrennt:** Jedes Feature liegt in einem eigenen Verzeichnis mit eigener Dokumentation und passenden Patchdateien.
* **Reine Quellcode-Patches:** Alle Patches sind Standard-Diffs gegen Open-Source-Code (AOSP / crDroid). Es werden keine proprietären Binärdateien (`.so`), Firmware-Blobs oder Schlüssel gespeichert.
* **Saubere Trennung:** Patches sind atomar aufgebaut und nach Android-Subsystemen getrennt (`packages/modules/*`, `frameworks/*` etc.).

---

## Allgemeine Anwendung

Jeder Unterordner enthält eine eigene `README.md` mit spezifischen Voraussetzungen, Ziel-Commits und Hinweisen.

Grundsätzlich können Patches mit Standard-Git-Befehlen angewendet werden:
```bash
# In das jeweilige Quellcode-Verzeichnis innerhalb des ROM-Trees wechseln
cd /pfad/zu/android/source/<ziel-subrepo>

# Den entsprechenden Patch anwenden
git apply /pfad/zu/android-patches-crdroid/<modul>/patches/<ziel_patch>.patch
```

---

## Verfügbare Module

* **[aptX Adaptive Audio Integration](aptx-adaptive/):** Vollständige Sitzungsanmeldung und Framework-Offload-Anbindung für Qualcomm Hardware-DSP-Audio.
  Basis: crDroid-Branch `16.0` (Android 16). Referenzgerät: OnePlus 13 (`dodge`). Andere Geräte: ungetestet.

---

## Probleme melden

Wenn ein Patch nicht anwendbar ist, nicht baut oder sich auf dem Referenz-Setup falsch verhält,
bitte ein Issue über das Formular **Patch problem** anlegen und die genaue Fehlermeldung einfügen.
Bluetooth-MAC-Adressen und Seriennummern vorher aus den Logs entfernen. Meldungen von anderen
Geräten sind als Information willkommen — bitte vorher den Haftungsausschluss unten lesen.

---

## Haftungsausschluss & Support-Hinweis

> [!IMPORTANT]
> **Privates Hobby-Projekt — Nutzung auf eigene Gefahr:**
> * **Privater Charakter:** Dieses Repository wird in meiner Freizeit als persönliches Hobby-Projekt gepflegt. Es handelt sich **nicht** um eine kommerzielle Distribution und nicht um eine Plattform mit Vollzeit-Support.
> * **Kein Support für alle Geräte:** Anpassungen, Tests und Messungen können logischerweise nur auf Geräten stattfinden, die ich selbst besitze und im Alltag nutze (wie dem OnePlus 13 Referenzgerät). Ich kann keinen Support, keine Portierungs-Garantie und keine Fehlerbehebung für Geräte anbieten, die mir physisch nicht vorliegen.
> * **Für erfahrene Anwender:** Die Patches richten sich an erfahrene ROM-Builder und Entwickler, die mit dem Android-Build-System vertraut sind, Compiler-Fehler interpretieren können und im Fehlerfall wissen, wie man ein Gerät debuggt oder wiederherstellt.
> * **Keine Gewährleistung:** Alles wird „wie besehen“ (*as is*) ohne jegliche Gewährleistung bereitgestellt. Jegliche Modifikationen am eigenen Gerät oder ROM-Build geschehen auf eigene Verantwortung.

---

## Lizenz

Soweit nicht in den Unterordnern anders angegeben, stehen alle Patches und Dokumentationen in diesem Repository unter der **Apache License, Version 2.0** (siehe [LICENSE](LICENSE)).
