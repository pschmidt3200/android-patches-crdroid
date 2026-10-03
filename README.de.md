# android-patches-crdroid

Eine strukturierte Sammlung modularer Patches, Framework-Verbesserungen und Hardware-Integrationen für **crDroid**.

Ziel dieses Repositories ist die Pflege sauberer, modularer Quellcode-Patches für crDroid — einschließlich hardwarespezifischer Anbindungen, wo ein Modul sie dokumentiert — ohne mitgelieferte proprietäre Hersteller-Binärdateien. Die Patches werden direkt in einen passenden crDroid-Quellbaum eingespielt.

**Derzeitiger ROM-Umfang: nur crDroid.** Jedes Modul nennt seinen crDroid-Branch und seine Referenzhardware.
Unterstützung für andere ROMs ist nicht belegt.

**Aktueller Repo-Status: öffentlich; GitHub Actions aktiv.** Die Modulprüfungen
laufen bei jedem Push. Kernelmodule behalten ihre Upstream-Lizenzbedingungen;
vor Build oder Weitergabe die jeweilige NOTICE lesen.

---

## Struktur des Repositories

Patches und Erweiterungen sind nach Themenbereichen in eigenständige Ordner unterteilt:

```text
android-patches-crdroid/
├── README.md                  # Allgemeine Übersicht und Anleitung (EN)
├── README.de.md               # Deutsche Dokumentation
├── LICENSE                    # Standardlizenz (abweichende Modulbedingungen unten)
├── .github/                   # Issue-Formular, Installer-Vorlage, CI und Release-Werkzeuge
│
├── aptx-adaptive/             # Bluetooth-Audio-Integration
│   ├── README.md              # Modul-Dokumentation & Voraussetzungen (EN)
│   ├── README.de.md           # Deutsche Modul-Dokumentation
│   ├── apply-patches.sh       # Automatisches Installations- & Prüfskript
│   ├── installer.json         # Titel, Patchreihenfolge und optionales Zielrepository
│   ├── NOTICE                 # Herkunftsnachweise, Referenz-Commits & Lizenzen
│   ├── LICENSE                # Modul-Lizenz (Apache 2.0)
│   └── patches/               # Git-Patches (Bluetooth, Frameworks, Settings, GameSpace, Device)
│
├── gms-fixes/                 # GMS-Kompatibilitätsanpassungen
├── gps-servers/               # SUPL- und NTP-Serverkonfiguration
├── donation-disable/          # Bereinigung von Spendenhinweisen
├── bbrv3/                     # TCP-Congestion-Control-Patch
└── susfs-core/                # Kernel-Patch-Korrekturen

```

---

## Wie die Module getrennt sind

Jedes Patch-Set ist ein **eigenständiger Modulordner**. Ein Modul hängt von keinem anderen ab,
verweist nicht darauf und dokumentiert es nicht — außer seine eigene README sagt es ausdrücklich.

| Ort | Gehört zu | Inhalt |
|---|---|---|
| Repository-Wurzel | der ganzen Sammlung | diese Übersicht, das Modulverzeichnis, der Haftungsausschluss und die Standard-`LICENSE` — **keine Patches** |
| `<modul>/` | genau einem Patch-Set | `README.md` + `README.de.md`, `NOTICE` (Upstream-Quellen und Referenz-Commits), `LICENSE`, `installer.json` und eigenständiges `apply-patches.sh` |
| `<modul>/patches/` | nur diesem Patch-Set | `.patch`-Dateien; jede beginnt mit einer Kopfzeile `# Target repository:`, die das Android-Zielrepository nennt |

Regeln für jedes Modul:

* **Ein Feature, ein Ordner** (`kebab-case`). Fremde Änderungen kommen nie in das `patches/` eines bestehenden Moduls.
* **Die Doku beschreibt nur das eigene Modul:** Voraussetzungen, crDroid-Branch, Referenz-Commits, getestete Geräte und bekannte Grenzen.
* **Der Support endet dort, wo die Modul-README endet.** Ein Modul ist nur so weit getestet, wie seine README es sagt.
* **Skripte bleiben im eigenen Modul** und fassen nur dessen `patches/`-Ordner an.
* **Fassungen werden nicht gemischt:** alle Patches eines Moduls aus demselben Commit dieses Repositories anwenden.
* **Die Liste *Verfügbare Module* unten ist die einzige Stelle, an der Module miteinander verlinkt werden.**

Diese Regeln werden bei jedem Push automatisch über GitHub Actions geprüft. `.github/scripts/check-modules.sh` prüft
Aufbau, Patch-Kopfzeilen und -Format sowie, ob Skript, READMEs und `NOTICE` dieselben Patches nennen;
`.github/scripts/test-apply-script.sh` lässt das `apply-patches.sh` jedes Moduls gegen einen
Wegwerf-Baum laufen. `.github/scripts/test-markdown-links.sh` prüft, dass externe URLs ignoriert
und fehlende lokale Linkziele abgelehnt werden, auch mit Fragmenten. Der Workflow *reference-check*
(`.github/scripts/check-reference.sh`) läuft zusätzlich bei Änderungen an Patches,
Anwendungsskripten, Referenznachweisen oder CI-Skripten und
prüft dann die Commits aus der `NOTICE` jedes Moduls. Jeden Montag um 06:23 UTC prüft er den
aktuellen crDroid-Branch `16.0`. Manuelle Läufe erlauben einen anderen Branch; ein leeres Branch-Feld
wählt die NOTICE-Commits. Ein viertes NOTICE-Feld `branch=<name>` ordnet während
Branch-Prüfungen den abweichenden Android-Branch eines Vendors zu (GMS: `bka`).
Die echten Patches werden geprüft, angewendet und zurückgenommen.
Danach muss jedes Quellrepository wieder sauber sein. Geladen werden nur die betroffenen Dateien.
Alle vier Skripte lassen sich lokal aus der Repository-Wurzel starten.

Die Installer-Logik wird einmalig in `.github/installer/apply-patches.sh.in` gepflegt.
Die `installer.json` jedes Moduls liefert Titel, Patchreihenfolge und optionales Zielrepository.
Das erzeugte `apply-patches.sh` bleibt ein vollständiges, eigenständiges Bash-Skript:
Anwender brauchen nur den Modulordner, Bash und Git. Python und Vorlage werden ausschließlich
zur Pflege dieses Repositories benötigt. Vorlage oder Metadaten ändern und danach erzeugen:

```bash
python3 .github/scripts/generate-installers.py
python3 .github/scripts/generate-installers.py --check
```

Erzeugte Installer nicht direkt bearbeiten. Die CI erkennt Abweichungen und prüft ungültige
Metadaten, eigenständige Nutzung und das bisherige Verhalten jedes Installers. Der Generator
validiert alle Module vor dem ersten Schreibzugriff. Bei einem E/A-Abbruch den gemeldeten Fehler
beheben und erneut erzeugen; `--check` verändert keine Dateien.

Die CI verwendet Standard-Runner vom Typ `ubuntu-latest`, die [für öffentliche Repositories kostenlos sind](https://docs.github.com/en/billing/concepts/product-billing/github-actions).
Jobs setzen bei privaten Repositories aus, haben Zeitlimits und laden keine Caches oder Artefakte
hoch. GitHub kann geplante Läufe verzögern und [deaktiviert sie nach 60 Tagen ohne Repo-Aktivität](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule);
vor dem Vertrauen auf die Wochenprüfung die Actions-Seite prüfen. Diese Tests belegen Anwendung
und Rücknahme der Patches, keinen ROM-Build oder Gerätetest.

---

## Richtlinien & Standards

* **Modular & getrennt:** Jedes Feature liegt in einem eigenen Verzeichnis mit eigener Dokumentation und passenden Patchdateien.
* **Reine Quellcode-Patches:** Die Standard-Diffs betreffen Quellcode und Build-Konfigurationen, die crDroid verwendet. Es werden keine proprietären Binärdateien (`.so`), Firmware-Blobs oder Schlüssel gespeichert.
* **Saubere Trennung:** Patches sind atomar aufgebaut und nach Android-Subsystemen getrennt (`packages/modules/*`, `frameworks/*` etc.).

---

## Allgemeine Anwendung

Jeder Unterordner enthält eine eigene `README.md` mit spezifischen Voraussetzungen, Ziel-Commits und Hinweisen.

Grundsätzlich können Patches mit Standard-Git-Befehlen angewendet werden:
```bash
# In das jeweilige Quellcode-Verzeichnis innerhalb des crDroid-Trees wechseln
cd /pfad/zu/crdroid/source/<ziel-subrepo>

# Den entsprechenden Patch anwenden
git apply /pfad/zu/android-patches-crdroid/<modul>/patches/<ziel_patch>.patch
```

---

## Verfügbare Module

* **[aptx-adaptive](aptx-adaptive/):** Bluetooth-Audio-Integration. Technische Details und Voraussetzungen im Modulordner.
* **[gms-fixes](gms-fixes/):** Kompatibilitätsanpassungen für Google-Dienste. Technische Details im Modulordner.
* **[gps-servers](gps-servers/):** Alternative SUPL- und NTP-Serverkonfiguration. Technische Details im Modulordner.
* **[donation-disable](donation-disable/):** Bereinigung von Spendenhinweisen in den Einstellungen. Technische Details im Modulordner.
* **[bbrv3](bbrv3/):** TCP-Congestion-Control-Patch. Technische Details im Modulordner.
* **[susfs-core](susfs-core/):** Kernel-Patch-Korrekturen. Technische Details im Modulordner.



---

## Probleme melden

Wenn ein Patch nicht anwendbar ist, nicht baut oder sich auf dem Referenz-Setup falsch verhält,
bitte ein Issue über das Formular **Patch problem** anlegen und Release-Tag oder Commit-SHA der
Patchfassung sowie die genaue Fehlermeldung einfügen. Den Patch-Commit zeigt `git rev-parse HEAD`
in diesem Repository an.
Bluetooth-MAC-Adressen und Seriennummern vorher aus den Logs entfernen. Meldungen von anderen
Geräten sind als Information willkommen — bitte vorher den Haftungsausschluss unten lesen.

---

## Modul-Releases

Das [Sammel-Release V1](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/v1.0)
hält die vollständige Quellpatch-Sammlung vom 01.10.2026 fest. Es enthält diese Modulstände:

| Modul | Release-Tag |
|---|---|
| `aptx-adaptive` | `aptx-adaptive-v1.2` |
| `gms-fixes` | `gms-fixes-v1.0` |
| `gps-servers` | `gps-servers-v1.0` |
| `donation-disable` | `donation-disable-v1.0` |

Modul-Tags verwenden `<modul>-v<version>`, Sammel-Tags `v<version>`. Versionen haben zwei
oder drei Zahlenbestandteile; Modulversionen erlauben einen Zusatz wie `-rc.1`.
Details zur Geräteabnahme und zum Teststand der einzelnen Module sind in den jeweiligen Modul-READMEs dokumentiert.



Separate Kernelstände vom 03.10.2026: `bbrv3-v1.0` und `susfs-core-v1.0`.
Sie gehören nicht zum unveränderlichen Sammelstand `v1.0`. Jeder erhält eigene
Release-Notizen und ein Modul-ZIP; SUSFS enthält ausschließlich unser Patchdatei-
Korrekturdelta. Erstprüfung und Upload erfolgten lokal; die Push-Prüfungen laufen jetzt über GitHub Actions.
`bbrv3-v1.1` ergänzt einen separaten Zusatzpatch, der `bbr3` zum TCP-Standard des Kernels macht.

Für den vollständigen V1-Stand:

```bash
git clone https://github.com/pschmidt3200/android-patches-crdroid.git
cd android-patches-crdroid
git switch --detach v1.0
```

Anschließend die Modul-README zum Prüfen und Anwenden im eigenen Quellbaum verwenden. Keine Dateien
aus verschiedenen Tags oder Commits mischen. Ein Tag bezeichnet die Patchfassung; Quellprüfungen
belegen noch keinen erfolgreichen ROM-Build oder Gerätetest.

Für ein einzelnes Modul `<tag>.zip` von der Release-Seite dieses Moduls herunterladen, zum Beispiel
`aptx-adaptive-v1.2.zip` beim [Release aptX v1.2](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/aptx-adaptive-v1.2).
Es enthält nur den Modulordner genau im Stand des Tags, mit eigenem `apply-patches.sh`, `NOTICE`
und `LICENSE`. GitHubs automatische *Source code*-Archive enthalten bei jedem Release immer das
ganze Repository im Stand dieses Tags.

Modul-Release-Seiten enthalten die Hinweise, das Modularchiv `<tag>.zip` und GitHubs Quellarchive;
das Sammel-Release hat kein zusätzliches Archiv. `.github/releases/<tag>.md` committen, den Commit
prüfen, danach unveränderliche Tags darauf setzen und `main` mit den Tags gemeinsam pushen.
Neue Notizen auf `main` starten
den Workflow *release*; er lässt sich auch manuell mit einem Tag starten. Das getaggte Modul muss
mit dem geprüften Commit übereinstimmen und darf keine uncommitteten Änderungen enthalten.
Der Helfer prüft **alle unveröffentlichten Kandidaten vor dem ersten Release**, einschließlich
Installer-Konsistenz und der vier Prüfungen unten. Bestehende Releases behalten Tag, Titel und
Hinweise; der Helfer hängt nur ein fehlendes Modularchiv einmalig an und ersetzt ein vorhandenes
nie. Ein manueller Workflow-Start ohne Tag erledigt das für alle Modul-Releases. Bei einem
Veröffentlichungsfehler nennt er bereits erzeugte Releases und bereits angehängte Archive; ein
erneuter Lauf prüft die verbleibenden Kandidaten. Neue Modul-Releases ersetzen nicht automatisch GitHubs globale
*Latest*-Auswahl. Sammel-Releases prüfen den vollständigen Repository-Stand und alle Module,
werden nach den ausstehenden Modul-Releases veröffentlicht und als *Latest* markiert.
Nur der Release-Job erhält `contents: write` über
GitHubs temporäres Job-Token. Er läuft ausschließlich auf `main` dieses öffentlichen Repos,
mit demselben kostenlosen Standard-Runner. Hochgeladen werden nur die Modularchive als
Release-Anhänge — keine Workflow-Artefakte und keine Caches.

Für das ausgewählte Modul führen Maintainer diese Prüfungen in der Repository-Wurzel aus:

```bash
MODULE=aptx-adaptive  # oder gms-fixes, gps-servers, donation-disable, bbrv3, susfs-core
python3 .github/scripts/generate-installers.py --check
bash .github/scripts/check-modules.sh
bash .github/scripts/test-apply-script.sh "$MODULE"
bash .github/scripts/check-reference.sh "$MODULE"
bash .github/scripts/check-reference.sh --branch 16.0 "$MODULE"
```

Mit angemeldeter GitHub CLI führt `GH_REPO=pschmidt3200/android-patches-crdroid bash
.github/scripts/release-modules.sh --check <tag>` die komplette Vorabprüfung ohne Veröffentlichung
aus. Ohne Tag werden alle Notizen in `.github/releases/` ausgewählt. Derselbe Helfer läuft im
Workflow. [`--verify-tag`](https://cli.github.com/manual/gh_release_create) verlangt ein bereits
auf GitHub vorhandenes Tag; der Helfer erstellt und verschiebt keine Tags.

Die Referenzprüfungen verwenden temporäre Quellbäume. Bei einem Fehler den Release-Vorgang stoppen:
Zielrepository, Quellstand und genaue Fehlermeldung festhalten, dann Patch oder dokumentierte
Referenz korrigieren. Die geprüften Änderungen committen und das Release-Tag auf diesen geprüften
Commit setzen.

**Bestehende Tags bleiben unverändert.** Ändern sich veröffentlichte Patches, ein neues Modul-Tag
verwenden, etwa `aptx-adaptive-v1.2`. Release-Notizen nennen Patch-Commit, Quellreferenzen, geändertes Verhalten und bekannte
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

Kernel-Ausnahmen: `bbrv3` erhält Kernel-GPL, einzelne Dateihinweise und die
`Dual BSD/GPL`-Kennzeichnung des BBR-Core. `susfs-core` behält Upstream-GPL-Version3
für sein Patchdatei-Delta; die GPL3/GPL2-Abgrenzung im kombinierten Kernel bleibt
ungeklärt. Eigene Doku/Metadaten/Installer bleiben Apache2.0. Die jeweiligen
LICENSE- und NOTICE-Dateien weisen diese Trennung aus.
