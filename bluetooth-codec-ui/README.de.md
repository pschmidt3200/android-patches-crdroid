# Bluetooth-Codec-Status, -Badges und -Auswahl für crDroid 16.0

Settings-Patches, die anzeigen, welcher Bluetooth-Audio-Codec und welche Abtastrate aktiv sind,
und die Auswahl von Codec und Abtastrate ermöglichen. Sie sind codec-unabhängig: Alles, was angezeigt
oder angeboten wird, kommt vom Bluetooth-Stack und vom verbundenen Gerät, zum Beispiel SBC, AAC,
aptX, aptX HD, LDAC oder — wenn der Stack es bereitstellt — aptX Adaptive.

**ROM-Umfang:** Dieses Paket ist derzeit nur für **crDroid 16.0** (Android 16) gedacht.
Unterstützung für andere ROMs ist nicht belegt.

Englische Fassung: [README.md](README.md)

---

## Was hinzukommt

| | |
|---|---|
| **Codec-Status** | SettingsLib liest die aktive Codec-Konfiguration eines Geräts und aktualisiert den Geräteeintrag, wenn sie sich ändert |
| **Codec-Badge** | die Geräteliste zeigt aktiven Codec und Rate, zum Beispiel `[aptX Adaptive 44.1 kHz]` |
| **Codec-Dialog** | in den Gerätedetails öffnet die Zeile „Medien-Audio“ einen Dialog mit den Codecs, die das Gerät anbietet |
| **Eintrag „Audio-Codec“** | die Seite „Verbundene Geräte“ hat einen eigenen Eintrag *Audio-Codec* für das aktive A2DP-Gerät, zeigt den aktuellen Codec und die Abtastrate an, mit Codec-Auswahl und Wahl der Abtastrate (*Automatisch* oder eine der Raten, die das Gerät für den aktuellen Codec anbietet) |

Den eigenständigen Eintrag gibt es, weil die Gerätedetails nicht immer erreichbar sind: Bei
Geräten, die zusätzlich LE Audio können, blendet Android die Zeile „Medien-Audio“ aus, und bei
Geräten mit Begleit-App legt diese App die Detailseite fest.

## Wie sich die Auswahl verhält

* Angefordert wird nur der Codec-Typ und auf Wunsch die Abtastrate, über die öffentliche API
  `BluetoothA2dp.setCodecConfigPreference`; alle anderen Felder bleiben automatisch. Der
  Bluetooth-Stack entscheidet, und Settings zeigt die danach zurückgelesene Konfiguration an,
  nicht die Anforderung.
* Angeboten werden nur Codecs und Abtastraten, die der Stack für das Gerät als auswählbar meldet.
* Eine Auswahl gilt für die aktuelle Verbindung. Nach einem erneuten Verbinden wird der Codec
  neu ausgehandelt.
* Mit ausgeschaltetem HD-Audio ist nur SBC wählbar.
* Solange LE Audio die aktive Route des Geräts ist, wird keine A2DP-Anforderung gesendet.
* Komponenten, die die Codec-Konfiguration selbst ändern, etwa ein Spielmodus, können eine
  manuelle Wahl später ersetzen.

Dieses Paket enthält keinen Codec. Das optionale Modul [`aptx-adaptive`](../aptx-adaptive/README.de.md)
ergänzt aptX Adaptive im Bluetooth-Stack auf seiner Referenzhardware; dieses Paket funktioniert
mit und ohne es.

## Voraussetzungen

* Ein crDroid-Quellbaum auf Branch **`16.0`** (Android 16). Die genauen Referenz-Commits stehen
  in [`NOTICE`](NOTICE).
* Es gibt keinen gerätespezifischen Code. Gebaut und genutzt wurde die Serie auf dem OnePlus 13.
* Ein gesicherter Quellbaum und ein gesichertes Gerät. Nicht während eines laufenden Builds patchen.

Zum Anwenden reichen **Git, die `.patch`-Dateien und ein passender crDroid-Quellbaum**.

---

## Zuordnung der Patchdateien

In dieser Reihenfolge anwenden. Die Pfade innerhalb eines Diffs sind relativ zum angegebenen
**Zielrepository**, nicht zur Android-Wurzel. Die Patches 2 bis 4 brauchen Patch 1; Patch 4
wird nach Patch 3 angewendet.

| # | Patchdatei | Zielrepository | Aufgabe |
|---|---|---|---|
| 1 | [crdroid_framework_settingslib_codec_status.patch](patches/crdroid_framework_settingslib_codec_status.patch) | `frameworks/base` | Codec-Status und Aktualisierung in SettingsLib |
| 2 | [crdroid_settings_bluetooth_codec_badges.patch](patches/crdroid_settings_bluetooth_codec_badges.patch) | `packages/apps/Settings` | Codec-Badges in der Geräteliste |
| 3 | [crdroid_settings_bluetooth_codec_menu.patch](patches/crdroid_settings_bluetooth_codec_menu.patch) | `packages/apps/Settings` | Codec-Dialog in den Gerätedetails |
| 4 | [crdroid_settings_bluetooth_codec_entry.patch](patches/crdroid_settings_bluetooth_codec_entry.patch) | `packages/apps/Settings` | Eintrag *Audio-Codec* mit Codec- und Abtastratenwahl |

---

## Anwenden

### Methode A: Automatisches Installationsskript (Empfohlen)

```bash
# 1. Trockenlauf (prüft alle Repositories, ändert keine Dateien):
./apply-patches.sh --check /pfad/zu/crdroid-sourcen

# 2. Alle Patches anwenden:
./apply-patches.sh /pfad/zu/crdroid-sourcen

# 3. (Optional) Zum sauberen Rückgängigmachen:
./apply-patches.sh --reverse /pfad/zu/crdroid-sourcen
```

Das Skript simuliert zuerst die ganze Serie an einer temporären Kopie der betroffenen Dateien —
die drei `packages/apps/Settings`-Patches übereinander — und ändert nichts, wenn etwas nicht
passt. Zielrepositories mit nicht committeten Änderungen weist es ab, außer mit `--allow-dirty`,
und es zeigt je Repository den Bezug zum Referenz-Commit aus der [`NOTICE`](NOTICE).

### Methode B: Manuelles Einspielen per Git

#### Einen einzelnen Patch einspielen:
Beide Platzhalter durch **absolute Pfade** ersetzen:

```sh
TARGET_REPO="/pfad/zum/crdroid/frameworks/base"
PATCH_FILE="/pfad/zu/codec-ui-patches/crdroid_framework_settingslib_codec_status.patch"
git -C "$TARGET_REPO" status --short
git -C "$TARGET_REPO" apply --check "$PATCH_FILE"
```

Eigene Änderungen vorher sichern. Nur wenn die Prüfung erfolgreich endet:

```sh
git -C "$TARGET_REPO" apply "$PATCH_FILE"
git -C "$TARGET_REPO" diff --check
git -C "$TARGET_REPO" diff --stat
```

Diese Dateien mit `git apply`, nicht mit `git am`, anwenden. Bei einem Fehler nicht mit dem
nächsten Befehl weitermachen.

### Alle vier Patches einspielen

`ANDROID_ROOT` ist die Wurzel des crDroid-Quellbaums, `PATCH_DIR` der Ordner, der die vier
`.patch`-Dateien **direkt** enthält. Beide Platzhalter ersetzen. Das Beispiel prüft alle vier
Diffs, bevor es den ersten anwendet; es ist keine atomare Transaktion.

```sh
(
set -eu
ANDROID_ROOT="/pfad/zum/android-quellbaum"
PATCH_DIR="/pfad/zu/codec-ui-patches"
patches="frameworks/base:crdroid_framework_settingslib_codec_status.patch
packages/apps/Settings:crdroid_settings_bluetooth_codec_badges.patch
packages/apps/Settings:crdroid_settings_bluetooth_codec_menu.patch
packages/apps/Settings:crdroid_settings_bluetooth_codec_entry.patch"
for item in $patches; do
    repository="${item%%:*}"
    patch="${item#*:}"
    git -C "$ANDROID_ROOT/$repository" apply --check "$PATCH_DIR/$patch"
done
for item in $patches; do
    repository="${item%%:*}"
    patch="${item#*:}"
    git -C "$ANDROID_ROOT/$repository" apply "$PATCH_DIR/$patch"
done
)
```

Die drei Settings-Patches ändern verschiedene Dateien, deshalb ist jede Prüfung am
Referenz-Commit für sich aussagekräftig. Bei Konflikten oder einer bereits angewendeten Fassung
stoppen; nichts erzwingen. Zurücknehmen mit `git -C "$TARGET_REPO" apply --reverse "$PATCH_FILE"`
in umgekehrter Reihenfolge der Tabelle.

Eine `.patch`-Datei wird nicht direkt geflasht: Für die Installation muss ein neues ROM gebaut werden.

## Am Gerät gegenprüfen

1. Ein Gerät verbinden und das Badge in der Geräteliste ansehen: Codec und Rate müssen zu dem
   passen, was das Gerät tatsächlich abspielt.
2. Auf „Verbundene Geräte“ *Audio-Codec* öffnen, einen anderen Codec wählen und prüfen, dass
   Badge und Eintrag die neue Konfiguration zeigen, nachdem der Stack sie übernommen hat.
3. Eine Abtastrate und danach wieder *Automatisch* wählen; jedes Mal den zurückgelesenen Wert prüfen.
4. Trennen und neu verbinden: Der Codec wird neu ausgehandelt, und der Eintrag folgt.

## Lizenz und Quellstände

Diese Dateien sind Diffs gegen crDroid-Quellen unter der Apache License 2.0. Die vollständige
Lizenz liegt als [`LICENSE`](LICENSE) bei. Geltende Upstream-Copyright- und Urheberhinweise
erhalten. Referenzstände und Haftungshinweise für den eigenen Build stehen in der [`NOTICE`](NOTICE).
