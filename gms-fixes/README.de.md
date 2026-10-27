# GMS-Kompatibilitätsfixes für crDroid

[English](README.md)

Vier unabhängig nutzbare Quellpatches für **crDroid 17.0 (Android 17)** mit
Evolution X `vendor_gms`, Branch `cnb`, unter `vendor/gms`.
Sie ändern Framework-Sichtbarkeit und Vendor-Buildkonfiguration. Sie installieren
keine GApps und enthalten keine Google-APKs. Andere GApps-Vendors sind nicht abgedeckt.

> **crDroid-17.0-Fassung: am Gerät geprüft.** Diese Patches zielen auf crDroid 17.0 und lassen
> sich an den [`NOTICE`](NOTICE)-Referenzcommits sauber anwenden und zurücknehmen. Am 27.10.2026
> wurden alle vier Patches auf einem OnePlus 13 mit dem 17.0-Build des Maintainers vom
> 25.10.2026, gebaut aus diesem Repository auf Stand `4bdecab`, geprüft; die
> Google-Clock-Berechtigung wirkt bei der derzeit installierten Clock-Version nicht. Siehe
> *Prüfung und Grenzen*. Die 16.0-Fassung bleibt auf dem Branch
> [`16.0`](https://github.com/pschmidt3200/android-patches-crdroid/tree/16.0/gms-fixes).

## Änderungen auswählen

| Patch | Zielrepository | Wirkung |
|---|---|---|
| [gms_query_visibility.patch](patches/gms_query_visibility.patch) | `frameworks/base` | Ergänzt ausschließlich `com.google.android.gms` in `config_forceQueryablePackages` für Apps mit Paketsichtbarkeitsproblemen; ursprünglicher Anlass: Net Analyzer. Keine zusätzlichen Rechte oder weiteren global sichtbaren Pakete. |
| [gms_google_clock_permission.patch](patches/gms_google_clock_permission.patch) | `vendor/gms` | Ergänzt ausschließlich für die Google-Uhr `SCHEDULE_EXACT_ALARM` in der privilegierten Berechtigungsliste. Die Berechtigungsprüfung bleibt aktiv. |
| [gms_uses_libraries.patch](patches/gms_uses_libraries.patch) | `vendor/gms` | Gleicht erforderliche/optionale uses-library-Metadaten in 18 Builddateien mit den APK-Manifesten ab; erhaelt die bestehenden gezielten Ausnahmen fuer `CustomizationBundlePrebuiltFullVersion` und `SafetyHubPrebuilt`. `PersistentBackgroundServices` fehlt im Branch `cnb`. |
| [gms_oneplus_package_selection.patch](patches/gms_oneplus_package_selection.patch) | `vendor/gms` | Entfernt die zehn unten genannten Pixel-Paketpräfixe aus Full-, Tablet-, Mini- und Pico-Produktlisten. Dies ist eine ausdrückliche OnePlus-Buildauswahl. |

Der uses-library-Patch ist eine gezielte Build-Ausnahme, **keine Implementierung
fehlender Bibliotheken**. Er belegt keine Laufzeitfunktion dieser Apps.
Die Paketauswahl entfernt folgende Präfixe einschließlich versionierter Namen:

* `FamilySpacePrebuilt`, `OdadPrebuilt`, `SearchSelectorPrebuilt`, `DeviceConnectivityServicePrebuilt`
* `NexusLauncherRelease`, `WallpaperPickerGoogleRelease`
* `SetupWizardPrebuilt`, `SetupWizardPixelPrebuilt`, `GooglePackageInstaller`
* `WeatherPixelPrebuilt`

Bei dieser Auswahl müssen crDroids Launcher, Einrichtungsassistent, Paketinstaller
und Wallpaper-Picker verfügbar bleiben. Play-Dienste, Play Store, Google-Uhr und
unabhängige Add-ons bleiben in den Produktlisten. Nicht für einen Pixel-Build verwenden.

## Anwenden und zurücknehmen

Sauberen Quellbaum ohne laufenden Build verwenden. Referenzen: [NOTICE](NOTICE).
**Der Helfer spielt alle vier Patches ein, einschließlich der Paketauswahl.**
Diese Auswahl vorher prüfen. Er simuliert die gesamte Serie vor dem ersten Schreibzugriff.

```bash
bash gms-fixes/apply-patches.sh --check /pfad/zu/crdroid
bash gms-fixes/apply-patches.sh /pfad/zu/crdroid
bash gms-fixes/apply-patches.sh --check --reverse /pfad/zu/crdroid
bash gms-fixes/apply-patches.sh --reverse /pfad/zu/crdroid
```

Nur den Sichtbarkeitsfix direkt auswählen:

```bash
PATCH_ROOT="$(pwd)/gms-fixes/patches"
ANDROID_ROOT=/pfad/zu/crdroid
git -C "$ANDROID_ROOT/frameworks/base" apply --check "$PATCH_ROOT/gms_query_visibility.patch"
git -C "$ANDROID_ROOT/frameworks/base" apply "$PATCH_ROOT/gms_query_visibility.patch"
# Den ausgewählten Patch zurücknehmen:
git -C "$ANDROID_ROOT/frameworks/base" apply --reverse "$PATCH_ROOT/gms_query_visibility.patch"
```

Andere Einzelpatches analog auswählen; ihr Ziel ist `vendor/gms`.
Bereits angewendete oder kollidierende Patches werden abgewiesen; keine automatische Wiederanwendung.

## Prüfung und Grenzen

Die öffentliche Fassung wird auf Format, Fehlerbehandlung des Helfers sowie echte
Anwendung/Rücknahme an [NOTICE](NOTICE)-Commits und aktuellen Upstream-Branches geprüft.
Branch-Prüfungen verwenden `17.0` für crDroid und NOTICEs `branch=cnb` für den Vendor:

```bash
bash .github/scripts/check-reference.sh gms-fixes
bash .github/scripts/check-reference.sh --branch 17.0 gms-fixes
```

**Geräteprüfung unter crDroid 17.0 (27.10.2026):** OnePlus 13, Build vom 25.10.2026 mit allen
vier Patches:
* `com.google.android.gms` steht in der Liste der für alle sichtbaren Pakete;
  Google-Play-Dienste (26.42) und Play Store (53.7) laufen.
* Die Datei für privilegierte Berechtigungen unter `/product` gibt Google Clock
  `SCHEDULE_EXACT_ALARM`, und ein Wecker hat wie gestellt geklingelt. Die installierte
  Clock-Version, über den Play Store aktualisiert, fordert stattdessen `USE_EXACT_ALARM` an, und
  das ist erteilt; dieser Berechtigungs-Patch wirkt bei dieser Version daher nicht.
* Keines der zehn entfernten Pixel-Pakete stammt aus dem Systemabbild. Zwei davon
  (`com.google.android.odad` und die Suchmaschinenauswahl der Einrichtung) wurden später nach
  `/data/app` installiert, mindestens eines über den Play Store; das liegt außerhalb des Builds.
* Das Geräteprotokoll zeigt keine uses-library-Fehler. Im Absturzprotokoll seit dem Start stehen
  SCONE (ein Datenverzeichnisfehler, drei abgelehnte Dienststarts im Hintergrund) und Magic
  Portrait (ein Fehler im Backup-Agent); keiner davon ist ein Fehler wegen fehlender Bibliothek,
  das belegt aber nicht, dass jede betroffene App funktioniert.

Net Analyzer, der ursprüngliche Sichtbarkeitsfall, wurde unter 17.0 nicht erneut ausgeführt.

**Dokumentierte ROM- und Geräteabnahme:** Auf dem Referenzgerät **OnePlus 13**
unter crDroid 16.0 (Build `v12.12-20261003`) live geprüft und abgenommen:
Boot ohne Bootloop, Google Play Services (26.37) und Play Store (53.3) stabil ohne Abstürze,
`com.google.android.gms` global abfragbar (`forceQueryable`), Google-Uhr-Wecker mit
`SCHEDULE_EXACT_ALARM` funktionsfähig, Launcher/PackageInstaller stabil. Bei Vendor-Updates
APK-Manifeste und Produktlisten erneut prüfen; die Änderungen hängen vom Referenzstand ab.
Lizenz und Herkunftsnachweise: [LICENSE](LICENSE), [NOTICE](NOTICE).
