# android-patches-crdroid

Eine strukturierte Sammlung modularer Patches, Framework-Verbesserungen und Hardware-Integrationen für **crDroid** und AOSP-basierte Custom ROMs.

Ziel dieses Repositories ist die Pflege sauberer, modularer Quellcode-Patches für AOSP/crDroid — einschließlich hardwarespezifischer Anbindungen, wo ein Modul sie dokumentiert — ohne mitgelieferte proprietäre Hersteller-Binärdateien. Die Patches werden direkt in einen passenden ROM-Quellbaum eingespielt.

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
Wegwerf-Baum laufen. `.github/scripts/test-markdown-links.sh` prüft, dass externe URLs ignoriert
und fehlende lokale Linkziele abgelehnt werden, auch mit Fragmenten. Der Workflow *reference-check*
(`.github/scripts/check-reference.sh`) läuft zusätzlich bei Änderungen an Patches,
Anwendungsskripten, Referenznachweisen oder CI-Skripten und
prüft dann die Commits aus der `NOTICE` jedes Moduls. Jeden Montag um 06:23 UTC prüft er den
aktuellen crDroid-Branch `16.0`. Manuelle Läufe erlauben einen anderen Branch; ein leeres Branch-Feld
wählt die NOTICE-Commits. Die echten Patches werden geprüft, angewendet und zurückgenommen.
Danach muss jedes Quellrepository wieder sauber sein. Geladen werden nur die betroffenen Dateien.
Alle vier Skripte lassen sich lokal aus der Repository-Wurzel starten.

Die CI verwendet Standard-Runner vom Typ `ubuntu-latest`, die [für öffentliche Repositories kostenlos sind](https://docs.github.com/en/billing/concepts/product-billing/github-actions).
Jobs setzen bei privaten Repositories aus, haben Zeitlimits und laden keine Caches oder Artefakte
hoch. GitHub kann geplante Läufe verzögern und [deaktiviert sie nach 60 Tagen ohne Repo-Aktivität](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule);
vor dem Vertrauen auf die Wochenprüfung die Actions-Seite prüfen. Diese Tests belegen Anwendung
und Rücknahme der Patches, keinen ROM-Build oder Gerätetest.

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
bitte ein Issue über das Formular **Patch problem** anlegen und Release-Tag oder Commit-SHA der
Patchfassung sowie die genaue Fehlermeldung einfügen. Den Patch-Commit zeigt `git rev-parse HEAD`
in diesem Repository an.
Bluetooth-MAC-Adressen und Seriennummern vorher aus den Logs entfernen. Meldungen von anderen
Geräten sind als Information willkommen — bitte vorher den Haftungsausschluss unten lesen.

---

## Reproduzierbare Releases

Für das bestehende aptX-Release den gesamten Modulstand über sein Tag auswählen:

```bash
git clone https://github.com/pschmidt3200/android-patches-crdroid.git
cd android-patches-crdroid
git switch --detach aptx-adaptive-v1.0
```

Anschließend die Modul-README zum Prüfen und Anwenden im eigenen Quellbaum verwenden. Keine Dateien
aus verschiedenen Tags oder Commits mischen. Ein Tag bezeichnet die Patchfassung; Quellprüfungen
belegen noch keinen erfolgreichen ROM-Build oder Gerätetest.

Die [Release-Seite](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/aptx-adaptive-v1.0)
enthält Hinweise und GitHubs Quellarchive. Für ein aptX-Release zuerst das unveränderliche Tag
anlegen und `.github/releases/<tag>.md` ergänzen. Neue Notizen auf `main` starten den Workflow
*release*; er lässt sich auch manuell mit einem Tag starten. Das getaggte Modul muss mit dem
geprüften Modul übereinstimmen. Alle vier Prüfungen unten müssen vor der Veröffentlichung bestehen.
Bestehende Releases bleiben unverändert. Nur der Release-Job erhält `contents: write` über
GitHubs temporäres Job-Token. Er läuft ausschließlich auf `main` dieses öffentlichen Repos,
mit demselben kostenlosen Standard-Runner und ohne Asset-Uploads.

Vor einem neuen aptX-Release führen Maintainer diese Prüfungen in der Repository-Wurzel aus:

```bash
bash .github/scripts/check-modules.sh
bash .github/scripts/test-apply-script.sh aptx-adaptive
bash .github/scripts/check-reference.sh aptx-adaptive
bash .github/scripts/check-reference.sh --branch 16.0 aptx-adaptive
```

Die Referenzprüfungen verwenden temporäre Quellbäume. Bei einem Fehler den Release-Vorgang stoppen:
Zielrepository, Quellstand und genaue Fehlermeldung festhalten, dann Patch oder dokumentierte
Referenz korrigieren. Die geprüften Änderungen committen und das Release-Tag auf diesen geprüften
Commit setzen.

**Bestehende Tags bleiben unverändert.** Ändern sich veröffentlichte Patches, ein neues Modul-Tag
verwenden, etwa `aptx-adaptive-v1.1`; `aptx-adaptive-v1.0` niemals verschieben, löschen oder erneut
verwenden. Release-Notizen nennen Patch-Commit, Quellreferenzen, geändertes Verhalten und bekannte
Grenzen. Quellprüfungen, ROM-Builds und Gerätetests getrennt ausweisen, einschließlich noch nicht
durchgeführter Prüfungen.

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
