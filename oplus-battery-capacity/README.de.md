# OPlus-Akkukapazitaet

`crdroid_oplus_battery_capacity.patch` reicht die vorhandene OPlus-Korrektur der
Voll-Ladekapazitaet (FCC) an den Android-Power-Supply-Pfad weiter. Ziel ist
**crDroid 17.0 / OnePlus sm8750**. Bisher meldete der generische Pfad die rohe FCC,
waehrend der OPlus-Meldepfad bereits eine geraetespezifische Korrektur verwendete.

## Motivation

Ziel ist eine herstellernahe Akkugesundheitsanzeige wie im Hersteller-ROM:
Android soll die vorhandene OPlus-Kapazitaetskorrektur nutzen und damit
herstellernahe Werte anzeigen. Anlass war eine niedrige Akkugesundheitsanzeige
aus der rohen, unkorrigierten Kapazitaet. Der angezeigte Wert soll aus den
Korrekturdaten des Geraets entstehen; eine feste Prozentzahl wird nicht vorgegeben.

## Abnahme

**Vorbereiteter Veroeffentlichungstext, erst nach bestandenem ROM-Test verwenden:**

> Abnahme abgeschlossen und OK; der Patch funktioniert wie erwartet. Ziel sind
> herstellernahe Werte der Akkugesundheitsanzeige durch die vorhandene
> OPlus-Kapazitaetskorrektur.

**Aktueller Stand:** Der Maintainer baut das ROM. Der Geraetetest ist noch nicht
bestaetigt; veroeffentlicht wird erst nach erfolgreichem Test.

**Technische Pruefungen bestanden:** Quellanwendung und Ruecknahme,
20 Hostfaelle mit ASan/UBSan und
negativer Gegenprobe sowie die Kompilierung der kompletten geaenderten
Treiberdatei mit Android clang r596125 / 22.0.2.

## Verhalten

Der Patch aendert `oplus/kernel/charger/v2/oplus_chg_gki.c` im Repository
`kernel/oneplus/sm8750-modules`. Die Formel folgt der bereits vorhandenen
[OPlus-Configfs-Kapazitaetsmeldung](https://github.com/crdroidandroid/android_kernel_oneplus_sm8750-modules/blob/204b190250343259fc7925c6f50a9365b2bff629/oplus/kernel/charger/v2/oplus_configfs.c):

```text
korrigierte FCC = min(rohe FCC + FCC-Koeffizient * SOH / 100, Designkapazitaet)
```

SOH ist der gemeldete Akkuzustand zwischen 1 und 100. Der Koeffizient kommt aus
der Akku-Messlogik; weder Zuschlag noch Prozentwert sind fest vorgegeben.

* `CHARGE_FULL` liefert bei gueltigen Metadaten die korrigierte FCC.
* `CHARGE_FULL_DESIGN` liest die aktuelle Designkapazitaet. Ohne Gauge oder ohne
  positiven Wert bleibt die zwischengespeicherte Designkapazitaet erhalten.
* Fehlender Gauge, gescheiterte Metadatenabfragen, ungueltiger SOH, nichtpositiver
  Koeffizient, nichtpositive rohe FCC oder fehlende nutzbare Designkapazitaet
  belassen die rohe FCC.
* Das Zwischenprodukt wird mit 64 Bit berechnet; beide Kapazitaetsmeldungen
  werden jeweils genau einmal von mAh in Mikroamperestunden umgerechnet.

Geaendert wird nur die Meldung. Ladeparameter, gelernte Gauge-Daten und der
separate UI-SOH werden weder beschrieben noch ersetzt. Der Patch bildet nicht
die gesamte Akkuzustandsanzeige eines Herstellers nach und misst den physischen
Verschleiss nicht unabhaengig. Eine feste Prozentanzeige ist kein Abnahmekriterium.

## Voraussetzungen und Installation

Ein kompatibler crDroid-17.0-Quellbaum mit `kernel/oneplus/sm8750-modules` wird
benoetigt. Die genaue oeffentliche Referenz steht in [NOTICE](NOTICE). Andere
Ladeimplementierungen und crDroid 16.0 gehoeren nicht zum Ziel dieses Moduls.

Im Modulverzeichnis ausfuehren:

```bash
./apply-patches.sh --check /pfad/zu/crdroid
./apply-patches.sh /pfad/zu/crdroid
# Quellaenderung auf einem weiterhin kompatiblen Baum zuruecknehmen:
./apply-patches.sh --reverse /pfad/zu/crdroid
```

Danach Kernel/ROM mit dem passenden Geraeteverfahren bauen und installieren.
Der Quellinstaller allein aendert kein bereits installiertes ROM.

## Verifikation

Hostpruefung mit Python 3 und einem C-Compiler mit ASan/UBSan:

```bash
python3 tests/check-capacity.py
```

Der Pruefer extrahiert die echten Helfer und Property-Zweige aus dem Patch und
kompiliert sie mit `-Wall -Wextra -Werror` und Sanitizern. Die Gauge-APIs sind
Test-Fixtures. Geprueft werden Korrektur, Alterungswert, Designgrenze, grosses
Zwischenprodukt, Einheiten und fehlende oder ungueltige Metadaten. Eine
Gegenprobe ohne Korrektur muss fehlschlagen. Das ersetzt weder Kernel-Link noch
ROM-Build oder Geraetepruefung.

Den echten Installer samt Rueckweg vom Repository-Hauptverzeichnis pruefen:

```bash
bash .github/scripts/check-reference.sh oplus-battery-capacity
bash .github/scripts/check-reference.sh --branch 17.0 oplus-battery-capacity
```

Nach Installation Android-FCC und Designkapazitaet mit frischen Gauge-Werten
aus demselben Boot vergleichen. Einen separaten SOH nicht stillschweigend mit
einer FCC-Messung gleichsetzen.

## Lizenz

Der Kernel-Patch behaelt **GPL-2.0-only** und die Oplus-Hinweise der Quelldatei;
siehe [LICENSE](LICENSE) und [NOTICE](NOTICE). Dokumentation, Test-Fixtures und
der generierte Installer stehen unter [Apache 2.0](LICENSE-APACHE-2.0).
