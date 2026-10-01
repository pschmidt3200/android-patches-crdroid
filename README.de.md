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
│
├── aptx-adaptive/             # aptX Adaptive DSP-Offload & Bluetooth-Anbindung
│   ├── README.md              # Modul-Dokumentation & Voraussetzungen (EN)
│   ├── README.de.md           # Deutsche Modul-Dokumentation
│   ├── apply-patches.sh       # Automatisches Installations- & Prüfskript
│   ├── NOTICE                 # Herkunftsnachweise & Lizenzen
│   └── patches/               # Git-Patches (Bluetooth, Frameworks, Settings)
│
└── [weitere-module]/          # Künftige Patch-Kategorien (Kernel, System etc.)
```

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

---

## Lizenz

Soweit nicht in den Unterordnern anders angegeben, stehen alle Patches und Dokumentationen in diesem Repository unter der **Apache License, Version 2.0** (siehe [LICENSE](LICENSE)).
