# Spendenanfragen in crDroid abschalten

[English](README.md)

Ein optionales Quellpatch-Modul für **crDroid 16.0 (Android 16)**.
Ich habe diesen Abschalter erstellt, weil ich diese Art der Spendenanfrage
in meinem ROM persönlich nicht leiden kann. Das richtet sich nicht gegen
Spenden allgemein.

Das Modul entfernt crDroids Spendenhinweise, Spendenseite und Spendenlinks
aus den Einstellungen. Maintainer-Namen samt OTA-Abfrage, Projekt-Credits,
Copyright und andere Über-Einträge bleiben erhalten. Telemetrie und eigenes
Branding sind getrennte Themen und werden hier nicht verändert.

## Änderungen

Für den vollständigen Abschalter **alle drei Patches gemeinsam anwenden**;
eine Teilanwendung lässt Zugänge zurück. Beide Android-Quellrepositories
werden benötigt.

| Patch | Zielrepository | Wirkung |
|---|---|---|
| [donation_components.patch](patches/donation_components.patch) | `packages/apps/crDroidSettings` | Löscht `DonateActivity` und dessen Netzabfrage zum Spendenfortschritt. Der bisherige Erinnerungs-Receiver bereinigt nur noch vorhandene Alarme, Benachrichtigungen und seinen Kanal; neue Erinnerungen werden weder geplant noch angezeigt. |
| [donation_about.patch](patches/donation_about.patch) | `packages/apps/crDroidSettings` | Entfernt den Spenden-Eintrag unter Über und leert den vorgegebenen Maintainer-Spendenlink. |
| [donation_settings.patch](patches/donation_settings.patch) | `packages/apps/Settings` | Entfernt die Registrierung der Spendenseite, den Spenden-Zugang durch mehrfaches Tippen auf die crDroid-Version in beiden Settings-Implementierungen sowie die Verarbeitung der Overlay-/OTA-Spendenlinks beim Maintainer. Dessen Name bleibt sichtbar und kopierbar. |

Der Receiver bleibt für Boot, Nutzerentsperrung und alte Erinnerungs-Broadcasts
registriert, **ausschließlich um alte Erinnerungen zu löschen**. Fehlt ein
Alarm, legt er keinen an. Ungenutzte Upstream-Übersetzungen, Layouts und Icons
bleiben im Ressourcenbaum; keine erreichbare Spendenoberfläche nutzt sie.
Website-, Community- und Sponsor-Credits bleiben. Inhalte externer Webseiten
liegen außerhalb dieses Moduls.

## Anwenden und zurücknehmen

Einen sauberen crDroid-Quellbaum ohne laufenden Build verwenden. Die
Referenz-Commits stehen in [NOTICE](NOTICE). Ältere Spenden-Anpassungen in
denselben Dateien vorher zurücknehmen oder abgleichen; der Helfer verweigert
Konflikte und bereits angewendete Patches. Er simuliert die gesamte Serie
auf Kopien, bevor er Dateien verändert.

Aus der Wurzel dieses Patchrepositories:

```bash
bash donation-disable/apply-patches.sh --check /pfad/zu/crdroid
bash donation-disable/apply-patches.sh /pfad/zu/crdroid
bash donation-disable/apply-patches.sh --check --reverse /pfad/zu/crdroid
bash donation-disable/apply-patches.sh --reverse /pfad/zu/crdroid
```

Die resultierenden Diffs prüfen, anschließend das ROM normal bauen und
installieren. Dies ist ein Quellpatch, kein flashbares ZIP und kein Schalter
für ein bereits installiertes ROM. Nach der Installation neu starten, damit
der Receiver alte Erinnerungen bereinigen kann. Die Rücknahme stellt die
ursprüngliche Spendenfunktion im Quellbaum wieder her; am Gerät erfordert
das einen erneuten ROM-Build und dessen Installation.

## Prüfung und Grenzen

Format, Fehlerbehandlung des Helfers sowie Anwendung/Rücknahme werden gegen
die [NOTICE](NOTICE)-Commits und den aktuellen crDroid-Branch `16.0` geprüft:

```bash
bash .github/scripts/check-modules.sh
bash .github/scripts/test-apply-script.sh donation-disable
bash .github/scripts/check-reference.sh donation-disable
bash .github/scripts/check-reference.sh --branch 16.0 donation-disable
```

Die Quelltests sind vollständig verifiziert:
- 34 von 34 Tests im Helfer-Test (`test-apply-script.sh`) erfolgreich.
- Saubere Anwendung und Rücknahme (3/3 Patches) auf den Referenz-Commits und crDroid `16.0` HEAD.
- Fehlerfreie Dry-Run-Simulation gegen den lokalen crDroid-Quellbaum.

**Dokumentierte ROM- und Geräteabnahme:** Auf dem Referenzgerät **OnePlus 13 (`dodge`, CPH2653)**
unter crDroid 16.0 (Build `Sat Oct 3 23:45:41 CEST 2026`) live verifiziert und abgenommen:
`DonateActivity` ist vollständig aus dem System entfernt (Klasse existiert nicht mehr, Intent-Aufrufe
schlagen mit `Activity class does not exist` fehl). `DonateReceiver` läuft ausschließlich im
Bereinigungsmodus für alte Alarme/Kanäle ohne neue Erinnerungen zu erzeugen. Mehrfaches Antippen
der crDroid-Version und Maintainer-Eintrag öffnen keine Spendenaufrufe mehr.
Lizenz und Herkunftsnachweise: [LICENSE](LICENSE), [NOTICE](NOTICE).


