# GMS-Kompatibilitätsfixes für crDroid

[English](README.md)

Vier unabhängig nutzbare Quellpatches für **crDroid 16.0 (Android 16)** mit
Evolution X `vendor_gms`, Branch `bka`, unter `vendor/gms`.
Sie ändern Framework-Sichtbarkeit und Vendor-Buildkonfiguration. Sie installieren
keine GApps und enthalten keine Google-APKs. Andere GApps-Vendors sind nicht abgedeckt.

## Änderungen auswählen

| Patch | Zielrepository | Wirkung |
|---|---|---|
| [gms_query_visibility.patch](patches/gms_query_visibility.patch) | `frameworks/base` | Ergänzt ausschließlich `com.google.android.gms` in `config_forceQueryablePackages` für Apps mit Paketsichtbarkeitsproblemen; ursprünglicher Anlass: Net Analyzer. Keine zusätzlichen Rechte oder weiteren global sichtbaren Pakete. |
| [gms_google_clock_permission.patch](patches/gms_google_clock_permission.patch) | `vendor/gms` | Ergänzt ausschließlich für die Google-Uhr `SCHEDULE_EXACT_ALARM` in der privilegierten Berechtigungsliste. Die Berechtigungsprüfung bleibt aktiv. |
| [gms_uses_libraries.patch](patches/gms_uses_libraries.patch) | `vendor/gms` | Setzt die uses-library-Buildprüfung nur für `CustomizationBundlePrebuiltFullVersion`, `SafetyHubPrebuilt` und `PersistentBackgroundServices` aus; entfernt eine überzählige `org.apache.http.legacy`-Deklaration bei `CrossDeviceAccessServicePrimary`. |
| [gms_oneplus_package_selection.patch](patches/gms_oneplus_package_selection.patch) | `vendor/gms` | Entfernt die zehn unten genannten Pixel-Paketpräfixe aus Full-, Tablet-, Mini- und Pico-Produktlisten. Dies ist eine ausdrückliche OnePlus-Buildauswahl. |

Der uses-library-Patch ist eine gezielte Build-Ausnahme, **keine Implementierung
fehlender Bibliotheken**. Er belegt keine Laufzeitfunktion dieser Apps.
Die Paketauswahl entfernt folgende Präfixe einschließlich versionierter Namen:

* `FamilySpacePrebuilt`, `OdadPrebuilt`, `SearchSelectorPrebuilt`, `DeviceConnectivityServicePrebuilt`
* `NexusLauncherRelease`, `WallpaperPickerGoogleRelease`
* `SetupWizardPrebuilt_versioned`, `SetupWizardPixelPrebuilt_versioned`, `GooglePackageInstaller`
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
Branch-Prüfungen verwenden `16.0` für crDroid und NOTICEs `branch=bka` für den Vendor:

```bash
bash .github/scripts/check-reference.sh gms-fixes
bash .github/scripts/check-reference.sh --branch 16.0 gms-fixes
```

**Für diese öffentliche Fassung wird kein neuer ROM-Build oder Gerätetest behauptet.**
Nach einem Build Boot, Net Analyzer, Google-Uhr-Wecker, Launcher/Recents,
Einrichtung und Paketinstallation auf dem Zielgerät prüfen. Bei Vendor-Updates
APK-Manifeste und Produktlisten erneut prüfen; die Änderungen hängen vom Referenzstand ab.
Lizenz und Herkunftsnachweise: [LICENSE](LICENSE), [NOTICE](NOTICE).
