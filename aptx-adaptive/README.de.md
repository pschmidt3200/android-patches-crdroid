# aptX Adaptive für crDroid

Stand: 2026-10-01. Quellpatch-Paket für **crDroid 16.0 (Android 16)**;
Referenzgeräte: **OnePlus 13 (`dodge`, CPH2653)** und **OnePlus Pad 3 / Pad 2 Pro (`erhai`, OPD2415)** (jeweils SM8750 / FastConnect 7900).

**ROM-Umfang:** Das Paket ist derzeit ausschließlich für **crDroid 16.0** ausgelegt.
Unterstützung für andere ROMs ist nicht belegt.

**Die grundlegenden Langzeitmessungen stammen aus der produktiven v39-Messreihe.** Die englische
Publikationsfassung übersetzt Bezeichner und Diagnosetexte; sie wurde am 01.10.2026 in crDroid 16.0
auf beiden Referenzgeräten (OnePlus 13 sowie OnePlus Pad 3 mit FiiO BTR17) gebaut und live verifiziert (Aushandlung bei 96 kHz,
dynamischer Wechsel zu 44,1 kHz Lossless, Hardware-DSP-Offload und 0 Bluetooth-Abstürze).
Eigene Tests auf abweichender Hardware oder geänderten Quellständen bleiben dennoch empfohlen.

## Was enthalten ist

- Native aptX-Adaptive-Registrierung und AIDL-Offload-Konfiguration im
  Bluetooth-Stack, einschließlich Qualcomm-Controller-START/STOP/UPDATE_MODE.
- Zuordnung des aptX-Adaptive-Audioformats zur Framework-Offload-Liste.
- GameSpace-Steuerung: für Gaming auf bestätigte **48 kHz + Low Latency**
  wechseln, anschließend zur vorherigen Qualitätskonfiguration zurückkehren.
  Der Status wird erst nach dem Controller-ACK bestätigt; unbestätigte Zustände
  bleiben sichtbar. Ein Controller-ACK ist kein Nachweis hörbaren Tons.
- R2.2-Property und gegenstellenabhängige Aushandlung bei **44,1 kHz** für den
  vorhandenen Lossless-Offload-Pfad. v39 bevorzugt bei passender R2.2-Gegenstelle
  Lossless im Alltag; eine explizite Nutzerwahl bleibt vorrangig.
- Codec-/Abtastratenanzeige in den Bluetooth-Einstellungen und aktualisierte
  auswählbare Codecs nach einem Reconnect.

## Zweck und Interoperabilität

Die Referenzgeräte wurden mit Hardware- und Vendor-Komponenten ausgeliefert, die für den Betrieb von aptX Adaptive und Snapdragon Sound ausgelegt sind. Beim Wechsel von der Hersteller-Firmware auf ein AOSP-basiertes Custom ROM entfällt die Host-seitige Anbindung, die für den Zugriff auf diese vorhandenen Komponenten erforderlich ist.

Dieses Projekt stellt die Host-seitige Integration im offenen Android-Bluetooth-Stack wieder her. Es liefert weder einen proprietären aptX-Encoder noch Qualcomm-Firmware, Vendor-Bibliotheken, SDK-Dateien oder eine Vervielfältigung des proprietären Codec-Algorithmus mit. Die eigentliche Codec-Kodierung verbleibt in den vorhandenen Vendor-/DSP-Komponenten des Geräts.

**Es wird kein aptX-Encoder implementiert oder mitgeliefert.** Der Encoder
liegt in der vorhandenen DSP-Firmware. Die Patches ergänzen Anmeldung,
Konfiguration und Steuerung für einen bereits geeigneten Vendor-Offload-Pfad.
Der 24-Bit-Offload-Container ist nicht mit einem Nachweis von 24-Bit-Lossless
oder eines durchgehend bittransparenten Android-Audiopfads gleichzusetzen.

## Voraussetzungen und Referenzstände

- Vollständiger, baubarer crDroid-Quellbaum auf Branch **`16.0`** (Android 16)
  mit passenden Gerätedateien und Vendor-Komponenten
  für das Zielgerät; die Android-Repository-Pfade unten müssen vorhanden sein.
- Kompatibler Qualcomm-AIDL-Audio-Provider, DSP-Firmware und Controller.
  Vendor-Bibliotheken, Firmware, APKs und ROM-Abbilder sind nicht enthalten.
- Eine Gegenstelle, die aptX Adaptive tatsächlich anbietet; für Lossless muss
  sie auch die benötigten R2.2-Fähigkeiten anbieten. Eine Property allein
  schafft keine fehlende Hardware- oder Firmware-Unterstützung.
- Sicherung des Geräts und der lokalen Änderungen sowie ein stillstehender
  Build-Baum. Nicht während eines laufenden Builds patchen oder zurückrollen.

Die Patches wurden für folgende Quellstände vorbereitet. Andere Stände müssen
neu auf Kontext und Verhalten geprüft werden; ein erfolgreicher `repo sync`
garantiert keine konfliktfreie Anwendung lokaler Patches.

| Android-Repository | Referenz-Commit |
|---|---|
| `packages/modules/Bluetooth` | `c575db642364` |
| `frameworks/base` | `a7b0e5e188fb` |
| `packages/apps/GameSpace` | `ca3a15a2cb77` |
| `packages/apps/Settings` | `62faa7098530` |
| `device/oneplus/sm8750-common` | `30beb69ed08f` |

Die vollständigen Commit-IDs und Lizenzhinweise stehen in [NOTICE](NOTICE).
Ein Port auf ein anderes Gerät ist ein eigener Integrations- und Testauftrag,
keine durch diesen Referenzstand zugesicherte Kompatibilität.

## Hardware- & Gerätekompatibilität

| Ebene | Komponente | Status & Hinweise |
|---|---|---|
| **Referenzgeräte** | **OnePlus 13** (`dodge`, CPH2653)<br>**OnePlus Pad 3 / Pad 2 Pro** (`erhai`, OPD2415) | Vollständig verifizierte Referenzplattformen (SM8750 / FastConnect 7900). |
| **Chipsatz / Controller** | Qualcomm **Snapdragon 8 Elite** (SM8750) mit **FastConnect 7900** | Benötigt Qualcomm AIDL Audio HAL und DSP-Offload-Firmware. |
| **Andere Geräte** | — | **Ungetestet.** Die Patches richten sich an crDroid 16.0; Patch 1 sendet FastConnect-7900-Herstellerbefehle und Patch 6 ist gerätespezifisch. Ein Port ist eigene Integrations- und Testarbeit. |
| **Gegenstellen (Kopfhörer/DACs)** | **FiiO BTR17** (Qualcomm QCC5181) | Referenz: 44,1 kHz Lossless, 48 / 96 kHz, 48 kHz Low Latency. |
| | **Bose QuietComfort Ultra 2 Earbuds** | Bietet nur 44,1 / 48 kHz an (kein 96 kHz); Link-/Aufbauereignisse erfasst, siehe „Belege und Grenzen“. |

---

## Ausführliche Patch-Übersicht: Wer macht was?

Um das Zusammenspiel der 6 Patches zu verstehen, folgt man der Audiokette von der App bis zur Hardware:

```text
[App / Spiel] 
    │
    ▼ (Patch 5: GameSpace erkennt Spielstart und schaltet auf Low-Latency)
[AudioPolicy / AudioFlinger] 
    │
    ▼ (Patch 2: Schaltet aptX Adaptive in der Framework-Offload-Liste frei)
[Bluetooth-Stack (btif / AIDL)] 
    │
    ▼ (Patch 1: Kern-Treiber — richtet DSP-Sitzung ohne Software-Encoder ein)
[Qualcomm Hexagon DSP & Controller] 
    │
    ▼ (Patch 6: System-Properties aktivieren Snapdragon Sound R2.2)
[Drahtlose Übertragung -> Kopfhörer / DAC]
    ▲
    │ (Patch 3 & 4: SettingsLib & UI zeigen aktives Codec-Badge an)
[Benutzeroberfläche]
```

### 1. `crdroid_bluetooth_aptx_adaptive_native.patch`
* **Ziel:** `packages/modules/Bluetooth`
* **Quellumfang:** das Bluetooth-Modul von crDroid
* **Hardware-Portabilität:** **Qualcomm-FastConnect-spezifisch** (Herstellerbefehle an den Controller); nur auf dem OnePlus 13 getestet
* **Rolle:** **Das Herzstück & der Protokoll-Treiber.**
* **Was er tut:** Ermöglicht die aptX-Adaptive-Offload-Sitzung in crDroid ohne Software-Encoder-Bibliothek und baut die native Sitzungsanmeldung an Qualcomms AIDL Audio-HAL (`AptxAdaptiveConfiguration`) auf. Er verhandelt die AVDTP-Fähigkeiten (44.1 kHz, 48 kHz, 96 kHz) und steuert die Raten- und Latenzumschaltung direkt über den DSP.
* **Wenn er weggelassen wird:** Es kann keine aptX-Adaptive-Sitzung starten; das System weicht auf normales aptX, AAC oder SBC aus.

### 2. `crdroid_framework_aptx_adaptive_offload.patch`
* **Ziel:** `frameworks/base`
* **Quellumfang:** crDroid-Framework-Code (`android.media.AudioSystem`); braucht Patch 1
* **Hardware-Portabilität:** kein gerätespezifischer Code; nur auf dem OnePlus 13 getestet
* **Rolle:** **Der System-Türöffner.**
* **Was er tut:** Ergänzt das Audioformat `AUDIO_FORMAT_APTX_ADAPTIVE` in `AudioSystem`, führt es bei den übrigen Bluetooth-Formaten und ordnet es dem aptX-Adaptive-Bluetooth-Codectyp zu.
* **Wenn er weggelassen wird:** Das Framework kennt kein Audioformat für aptX Adaptive und kann den ausgehandelten Bluetooth-Codec keinem Offload-Format zuordnen.

### 3. `crdroid_framework_settingslib_codec_status.patch`
* **Ziel:** `frameworks/base` (`packages/SettingsLib`)
* **Quellumfang:** crDroid-SettingsLib-Code
* **Hardware-Portabilität:** kein gerätespezifischer Code; nur auf dem OnePlus 13 getestet
* **Rolle:** **Die interne Status-Brücke.**
* **Was er tut:** Ergänzt `A2dpProfile.getCodecStatus()` und aktualisiert einen Geräteeintrag, wenn sich die Codec-Konfiguration ändert (`ACTION_CODEC_CONFIG_CHANGED`).
* **Wenn er weggelassen wird:** Patch 4 baut nicht (er ruft `getCodecStatus()` auf), und die Geräteliste aktualisiert sich nach einem Codec-Wechsel nicht.

### 4. `crdroid_settings_bluetooth_codec_badges.patch`
* **Ziel:** `packages/apps/Settings`
* **Quellumfang:** crDroid-Settings-Code; **braucht Patch 3**
* **Hardware-Portabilität:** kein gerätespezifischer Code; nur auf dem OnePlus 13 getestet
* **Rolle:** **Die Benutzeroberfläche & Anzeige.**
* **Was er tut:** Zeigt das aktive Codec-Badge (z. B. *aptX Adaptive*, *aptX Lossless*, *96 kHz*) in der Zusammenfassung eines verbundenen Geräts in der Bluetooth-Geräteliste an.
* **Wenn er weggelassen wird:** Der Ton läuft zwar, aber die Einstellungs-App zeigt nur ein Standard- oder leeres Label.

### 5. `crdroid_gamespace_bluetooth_gaming_audio.patch`
* **Ziel:** `packages/apps/GameSpace`
* **Quellumfang:** die GameSpace-App von crDroid; braucht Patch 1
* **Hardware-Portabilität:** kein gerätespezifischer Code; nur auf crDroid `16.0` / OnePlus 13 getestet
* **Rolle:** **Automatische Latenzsteuerung beim Spielen.**
* **Was er tut:** Klinkt sich in die GameSpace-Ereignisse ein. Sobald ein Spiel gestartet wird, schaltet der Bluetooth-Stack automatisch von High-Quality (~348 ms) auf Low-Latency (~117 ms). Beim Beenden des Spiels wird das vorherige HQ- oder Lossless-Profil nahtlos wiederhergestellt.
* **Wenn er weggelassen wird:** Spiele laufen mit Standard-Latenz oder müssen manuell geschaltet werden.

### 6. `crdroid_aptx_r2_2_property.patch`
* **Ziel:** `device/oneplus/sm8750-common` (oder der geräteeigene Device-Tree)
* **Quellumfang:** **gerätespezifische Vorlage**
* **Rolle:** **Hardware- & Treiber-Schalter.**
* **Was er tut:** Setzt die erforderlichen `persist.vendor.qcom.bluetooth.*`-Properties, damit der Qualcomm-Stack und die DSP-Firmware Snapdragon Sound R2.2 und aptX Adaptive freigeben.
* **Für andere Geräte:** Diese Properties in das eigene `vendor.prop` oder `device.mk` übernehmen.

---

## Zuordnung der Patchdateien

In dieser Reihenfolge anwenden. **Die Pfade innerhalb eines Diffs sind relativ zum
angegebenen Zielrepository, nicht zur Android-Wurzel** — `framework/java/android/bluetooth/`
gehört zum Beispiel zum Bluetooth-Repository. Nicht über ältere Fassungen oder Prototypen
dieser Patches stapeln.

| # | Patchdatei | Zielrepository | Aufgabe |
|---|---|---|---|
| 1 | [crdroid_bluetooth_aptx_adaptive_native.patch](patches/crdroid_bluetooth_aptx_adaptive_native.patch) | `packages/modules/Bluetooth` | Codec-Kern, HAL/Offload & Sitzungssteuerung |
| 2 | [crdroid_framework_aptx_adaptive_offload.patch](patches/crdroid_framework_aptx_adaptive_offload.patch) | `frameworks/base` | AudioPolicy Offload-Freigabe |
| 3 | [crdroid_framework_settingslib_codec_status.patch](patches/crdroid_framework_settingslib_codec_status.patch) | `frameworks/base` | SettingsLib Status-Ereignisse |
| 4 | [crdroid_settings_bluetooth_codec_badges.patch](patches/crdroid_settings_bluetooth_codec_badges.patch) | `packages/apps/Settings` | Codec-Badges in den Einstellungen |
| 5 | [crdroid_gamespace_bluetooth_gaming_audio.patch](patches/crdroid_gamespace_bluetooth_gaming_audio.patch) | `packages/apps/GameSpace` | Automatische Gaming-Low-Latency-Umschaltung |
| 6 | [crdroid_aptx_r2_2_property.patch](patches/crdroid_aptx_r2_2_property.patch) | `device/oneplus/sm8750-common` | System-Properties für Snapdragon Sound |

---

## Anwenden

### Methode A: Automatisches Installationsskript (Empfohlen)

Das Repository enthält das Hilfsskript `apply-patches.sh`, das alle 6 Patches vorab prüft und in einem Schritt einspielt:

```bash
# 1. Trockenlauf (prüft alle Repositories, ändert keine Dateien):
./apply-patches.sh --check /pfad/zu/crdroid-sourcen

# 2. Alle Patches anwenden:
./apply-patches.sh /pfad/zu/crdroid-sourcen

# 3. (Optional) Zum sauberen Rückgängigmachen:
./apply-patches.sh --reverse /pfad/zu/crdroid-sourcen
```

Was das Skript tut, bevor es etwas ändert:

* **Es simuliert die ganze Serie** an einer temporären Kopie der betroffenen Dateien. Die beiden
  `frameworks/base`-Patches werden übereinander geprüft, nicht jeder einzeln gegen den
  unveränderten Baum. Passt etwas nicht, wird nichts geändert (Exit-Code 2).
* **Es verweigert Zielrepositories mit nicht committeten Änderungen** (Exit-Code 4), damit eigene
  Änderungen nicht mit der Serie vermischt werden. `--allow-dirty` hebt das bewusst auf. Beim
  Rückgängigmachen gilt das nicht, denn eine angewendete Serie ist selbst eine offene Änderung.
* **Es zeigt je Repository den Bezug zum Referenz-Commit** aus der [`NOTICE`](NOTICE):
  `matches reference`, `newer than reference` oder `not in local history`. Das ist nur eine
  Auskunft — ein neuerer Baum wird nicht abgewiesen —, aber die erste Stelle zum Nachsehen,
  wenn ein Patch scheitert.

Bricht es trotzdem mittendrin ab (Exit-Code 3, nur möglich, wenn sich der Baum während des Laufs
ändert), listet es die schon bearbeiteten Patches und den Weg zum Rückgängigmachen auf.

---

### Methode B: Manuelles Einspielen per Git

Zum manuellen Anwenden reichen **Git, die `.patch`-Dateien und ein passender crDroid-Quellbaum**.

#### Einen einzelnen Patch einspielen:
Den Zielrepository-Pfad aus der Tabelle oder der ersten Kopfzeile des Patches nehmen. Beide Platzhalter durch **absolute Pfade** ersetzen:

```sh
TARGET_REPO="/pfad/zum/crdroid/packages/modules/Bluetooth"
PATCH_FILE="/pfad/zu/aptx-patches/crdroid_bluetooth_aptx_adaptive_native.patch"
git -C "$TARGET_REPO" status --short
git -C "$TARGET_REPO" apply --check "$PATCH_FILE"
```

Eigene Änderungen vorher sichern. Nur wenn die Prüfung erfolgreich endet:

```sh
git -C "$TARGET_REPO" apply "$PATCH_FILE"
git -C "$TARGET_REPO" diff --check
git -C "$TARGET_REPO" diff --stat
```

`git apply --check` ändert nichts. `git apply` verändert die Quelldateien, erstellt
aber keinen Commit und installiert nichts auf dem Telefon. Die Bluetooth-Datei
allein ist nicht das vollständige Funktionspaket; die Zuordnung der übrigen fünf
Patches steht in der Tabelle. Diese Dateien mit `git apply`, nicht mit `git am`,
anwenden. Bei einem Fehler nicht mit dem nächsten Befehl weitermachen.

### Alle sechs Patches einspielen

`ANDROID_ROOT` ist die Wurzel des crDroid-Quellbaums, `PATCH_DIR` der Ordner,
der die sechs `.patch`-Dateien **direkt** enthält. Beide Platzhalter ersetzen.
Zuerst alle Zielrepositories mit `git status --short` auf fremde Änderungen
prüfen und den gewünschten Quellstand sichern. Das Beispiel prüft alle sechs
Diffs, bevor es den ersten anwendet; es ist keine atomare Transaktion.

```sh
(
set -eu
ANDROID_ROOT="/pfad/zum/android-quellbaum"
PATCH_DIR="/pfad/zu/aptx-patches"
patches="packages/modules/Bluetooth:crdroid_bluetooth_aptx_adaptive_native.patch
frameworks/base:crdroid_framework_aptx_adaptive_offload.patch
frameworks/base:crdroid_framework_settingslib_codec_status.patch
packages/apps/Settings:crdroid_settings_bluetooth_codec_badges.patch
packages/apps/GameSpace:crdroid_gamespace_bluetooth_gaming_audio.patch
device/oneplus/sm8750-common:crdroid_aptx_r2_2_property.patch"
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

Bei Konflikten stoppen und den betroffenen Hunk gegen Upstream prüfen. Kein
erzwungenes Apply und kein destruktiver Reset zum Ausprobieren. Mit
`git apply --reverse --check` lässt sich die Rücknehmbarkeit einer bereits
angewendeten Fassung prüfen; eine tatsächliche Rücknahme muss in umgekehrter
Reihenfolge und nach Sicherung eigener Änderungen erfolgen.

### Rücknahme, erneuter Sync und Build

Eine erfolgreiche Vorwärtsprüfung bedeutet: der Patch ist im aktuellen Baum
anwendbar. Schlägt sie fehl, aber `git -C "$TARGET_REPO" apply --reverse --check "$PATCH_FILE"`
gelingt, entspricht der Baum den Änderungen bereits; nicht noch
einmal anwenden. Scheitern beide Prüfungen, sind etwa ein anderer Quellstand,
Teiländerungen oder ein falsches Zielrepository möglich: Hunk und Diffs prüfen,
nichts erzwingen. `--reverse --check` prüft nur die Rücknehmbarkeit.

Eine gewollte Rücknahme erfolgt nach Sicherung eigener Änderungen mit
`git -C "$TARGET_REPO" apply --reverse "$PATCH_FILE"`. Beim gesamten Paket die
Reihenfolge der Tabelle umkehren. Nicht während eines laufenden Builds arbeiten.

Anschließend `git diff --check` und die Diffs in jedem Zielrepository prüfen und
den regulären, gerätespezifischen crDroid-Build durchführen. Build, Tests,
Signierung und Installation liegen beim Anwender. `repo sync` selbst wendet
dieses Paket nicht automatisch an; nach einem erneuten Sync Vorwärts-/Rückwärts-
prüfung und Inhalt wieder prüfen. Für die Installation auf dem Gerät muss ein
neues ROM gebaut und nach dem üblichen gerätespezifischen Verfahren installiert
werden; eine `.patch`-Datei wird nicht direkt geflasht.

## Am Gerät gegenprüfen

1. Mit einer geeigneten Senke koppeln, aptX Adaptive auswählen und Ton prüfen.
   Codec, Rate und Container anhand der Geräteanzeige und Bluetooth-/Audio-Logs
   kontrollieren; „Codec auswählbar“ allein genügt nicht.
2. Mit der FiiO-Referenz bei 44,1 kHz auch die **LS-Anzeige mit Ton** prüfen.
   Telefonseitige Aushandlung allein beweist keinen Lossless-Modus der Senke.
3. Das Bluetooth-Gaming-Audio-Profil in GameSpace aktivieren: bestätigte 48 kHz
   müssen vor bestätigtem LL stehen. Beim Verlassen des Spiels die vorherige
   Qualitätskonfiguration kontrollieren, auch bei schnellem Start/Ende/Start.
4. Pause/Resume sowie Disconnect/Reconnect prüfen, einschließlich Codec-Menü
   und Gaming-Status. Fremde Codecs dürfen keine aptX-Moduskommandos erhalten.
5. Erst nach diesen Prüfungen einen längeren Alltagstest bewerten. Unbestätigte
   Controller-Zustände, Audioaussetzer oder Neustarts nicht als Erfolg werten.

## Belege und Grenzen

Die dokumentierten Referenzläufe umfassen GameSpace-Umschaltungen aus 44,1-kHz-
Lossless und HQ nach 48-kHz-LL und zurück. Eine Vergleichsmessung des
dokumentierten Nutzerpfads ergab **117,55 ms gegenüber 348,47 ms**; diese Werte
sind keine universelle Latenzgarantie für andere Anwendungen oder Senken.

Für den produktiven v39-Stand wurden vom 20.09. bis 01.10.2026 **181 Logstunden
in einem 249-Stunden-Fenster** ausgewertet, einschließlich eines Neustarts:

- Keine Bluetooth-/Audio-/system_server-Abstürze in den erfassten Stunden.
- Keine FiiO-Linkverluste im Fenster; **234/234 UPDATE_MODE akzeptiert**.
- **203 START und 204 STOP**; der einzelne Überhang gehört zu einer fehlenden
  Logstunde. Die Folge war ansonsten START/STOP, nicht ein ungeklärter STOP-Sturm.

Das ist keine lückenlose 249-Stunden-Messung und kein Nachweis für beliebige
Hardware. Bei der Bose wurden im selben Fenster elf Link-/Aufbauereignisse
erfasst, zwei davon bei laufendem Strom; daraus folgt keine Zusage aussetzerfreien
Betriebs. Persönliche Rohmitschnitte sind nicht Teil dieses Publikationspakets.

**Bekannte Grenzen:**

- FiiO BTR17 ist die Referenz für 44,1/48/96 kHz. Die getestete Bose QC Ultra 2 Earbuds
  bietet nur 44,1/48 kHz an; Fosi Audio K7 bietet kein aptX Adaptive an. Eine
  zweite vollständig vermessene 48/96-kHz-Gegenstelle fehlt.
- Der Low-Latency-Gewinn wurde mit LL am Controller und HQ am DSP beobachtet.
  Das Paket verspricht keinen eigenständigen DSP-LL-Umbau und ist nicht der
  separate ältere Codec „aptX Low Latency“.
- Lossless-Aushandlung, LS-Anzeige und Ton beweisen keine Ende-zu-Ende-
  Bittransparenz. Der dokumentierte Android-Musikpfad arbeitet weiterhin mit
  48 kHz und kann vor dem Codec umrechnen. Ein eigener bittransparenter
  A2DP-Ausgabepfad ist nicht enthalten.
- Das Paket schaltet keine fehlenden Codec-Lizenzen, Vendor-Funktionen oder
  Hardwarefähigkeiten frei und enthält keinen allgemeinen MMAP-/AudioPolicy-Fix.

## Support-Hinweis & Haftungsausschluss

> [!IMPORTANT]
> * **Privates Projekt:** Dies ist ein privates Hobby-Projekt, entstanden für den eigenen Gebrauch auf konkreter Hardware. Es ist **keine** kommerziell gepflegte Software-Distribution.
> * **Grenzen beim Geräte-Support:** Prüfen und Fehler beheben kann ich nur auf Hardware, die ich selbst besitze (das OnePlus 13 als Referenzgerät). Anfragen zur Portierung oder Fehlersuche auf anderen Geräten kann ich deshalb nicht aktiv bedienen.
> * **Verantwortung beim Builder:** Patches einspielen und ROMs bauen setzt technisches Wissen voraus. Build, Tests und die Wiederherstellung des Geräts im Fehlerfall liegen in eigener Verantwortung.

## Lizenz, Risiken und Kurzcheckliste

[NOTICE](NOTICE) beschreibt Upstream-Lizenzen, Referenzstände und Abgrenzung der
Vendor-Komponenten. Die vollständige Apache-2.0-Lizenz liegt als [LICENSE](LICENSE)
bei; sie muss mitgeliefert werden und anwendbare Upstream-Hinweise müssen erhalten bleiben.
Das Paket ist keine offizielle Freigabe der genannten Projekte oder Hersteller.
Es gibt keine Kompatibilitäts-, Qualitäts- oder Supportzusage. Eigene Builds
und Flash-Vorgänge können Datenverlust, Boot- oder Audiofehler verursachen und
Hersteller-Garantie-/Supportbedingungen berühren; gesetzlich nicht abdingbare
Rechte werden damit nicht pauschal ausgeschlossen.

1. **Voraussetzungen prüfen:** Hardware, Senke, Vendor-Offload, Quellstand,
   Lizenzen und Backups; laufende Builds stoppen.
2. **Anwenden:** je Zielrepository zuerst `git apply --check`, dann `git apply`;
   Diffs und Parität prüfen, Fassungen nicht mischen.
3. **Bauen:** regulären gerätespezifischen ROM-Build und Tests ausführen.
4. **Gegenprüfen:** Ton, Codec/Rate, ACK, Gaming-Wechsel und Reconnect am Gerät.
