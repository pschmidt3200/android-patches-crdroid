# GPS-Serverauswahl für crDroid

[English](README.md)

Zwei unabhängig wählbare Konfigurationspatches für **crDroid 16.0 (Android 16)**,
OnePlus `device/oneplus/sm8750-common`, Datei `configs/gps/gps.conf`.
Die Auswahl erfolgt beim Build; es entsteht kein neues Android-Einstellungsmenü.

## Einen, beide oder keinen auswählen

| Auswahl | Patch | Konfiguration |
|---|---|---|
| GrapheneOS-SUPL-Proxy | [sm8750_grapheneos_supl.patch](patches/sm8750_grapheneos_supl.patch) | Setzt `SUPL_HOST=supl.grapheneos.org`, `SUPL_PORT=7275` anstelle der auskommentierten Referenz-Platzhalter. |
| Deutscher GNSS-NTP-Pool | [sm8750_ntp_germany.patch](patches/sm8750_ntp_germany.patch) | Ersetzt `NTP_SERVER=time.xtracloud.net` durch `NTP_SERVER=0.de.pool.ntp.org`. Dies ist eine regionale Auswahl. |
| Upstream-Konfiguration | Keinen Patch anwenden oder ausgewählten Patch zurücknehmen | Behält ursprüngliche SUPL-Platzhalter beziehungsweise NTP-Hostname des Referenzbaums. |

GrapheneOS beschreibt den SUPL-Proxy und seine zusätzlichen Schutzmaßnahmen in
seiner [FAQ](https://grapheneos.org/faq#other-connections). Eine Hostname-Änderung
überträgt diese Schutzmaßnahmen nicht auf crDroid. Carrier-/Modem-Konfiguration
kann die Datei übersteuern; tatsächliche Servernutzung muss am Gerät belegt werden.
Der [deutsche NTP-Pool](https://www.ntppool.org/en/zone/de) umfasst mehrere Server;
die Auswahl ändert nicht Androids allgemeinen Netzwerkzeitdienst.
Schnellerer Fix, höhere Genauigkeit oder belegter Datenschutzgewinn werden nicht behauptet.
PSDS-/XTRA-URLs, GNSS-Fähigkeiten und Notfalleinstellungen bleiben unverändert.

## Eine Alternative anwenden

In der Wurzel dieses Repositories ausführen, während kein Build den Zielbaum verwendet:

```bash
PATCH_ROOT="$(pwd)/gps-servers/patches"
ANDROID_ROOT=/pfad/zu/crdroid
# Nur SUPL auswählen:
git -C "$ANDROID_ROOT/device/oneplus/sm8750-common" apply --check "$PATCH_ROOT/sm8750_grapheneos_supl.patch"
git -C "$ANDROID_ROOT/device/oneplus/sm8750-common" apply "$PATCH_ROOT/sm8750_grapheneos_supl.patch"
# Upstream-SUPL wiederherstellen:
git -C "$ANDROID_ROOT/device/oneplus/sm8750-common" apply --reverse "$PATCH_ROOT/sm8750_grapheneos_supl.patch"
```

Für die NTP-Auswahl dieselben Befehle mit `sm8750_ntp_germany.patch` verwenden.
Beide Patches können unabhängig voneinander angewendet und zurückgenommen werden.

## Beide Alternativen anwenden

**Der Helfer wählt beide Alternativen.** `--check` simuliert die Serie auf Kopien;
fehlende, kollidierende oder lokal geänderte Ziele werden abgewiesen.

```bash
bash gps-servers/apply-patches.sh --check /pfad/zu/crdroid
bash gps-servers/apply-patches.sh /pfad/zu/crdroid
bash gps-servers/apply-patches.sh --check --reverse /pfad/zu/crdroid
bash gps-servers/apply-patches.sh --reverse /pfad/zu/crdroid
```

## Prüfung und Grenzen

Referenzen: [NOTICE](NOTICE). Geprüft werden beide Patches als Serie sowie echte
Anwendung/Rücknahme an Referenz-Commits und aktuellem Branch:

```bash
bash .github/scripts/check-reference.sh gps-servers
bash .github/scripts/check-reference.sh --branch 16.0 gps-servers
```

**Dokumentierte ROM- und Geräteabnahme:** Auf dem Referenzgerät **OnePlus 13 (`dodge`, CPH2653)**
unter crDroid 16.0 (Build `Sat Oct 3 23:45:41 CEST 2026`) live verifiziert und abgenommen:
In `/odm/etc/gps.conf` sind `SUPL_HOST=supl.grapheneos.org`, `SUPL_PORT=7275` sowie
`NTP_SERVER=0.de.pool.ntp.org` aktiv konfiguriert. Der GNSS-Standortdienst (`GnssService`)
ist funktionsfähig und liefert Satelliten-Fixes über Multi-Frequenz-Signale (GPS, Galileo, BeiDou, GLONASS).
Lizenz und Herkunftsnachweise: [LICENSE](LICENSE), [NOTICE](NOTICE).

