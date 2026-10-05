# LE-Audio-Fixes für crDroid 16.0

Drei Korrekturen, die LE Audio mit Empfängern wie dem FiiO BTR17 nutzbar machen:

1. **Verbindung** — Empfänger, die EATT anbieten, die gesammelte Attributabfrage des Stacks aber nie
   beantworten, können überhaupt verbinden (ein Flagwert zur Bauzeit).
2. **Codec-Vorgabe** — eine gewählte Abtastrate oder Frame-Dauer kommt tatsächlich im Stream an,
   statt nur gespeichert und ignoriert zu werden (Stack-Korrektur).
3. **Mehr Media-Konfigurationen** — 32 kHz (7,5 und 10 ms) und 24 kHz / 7,5 ms stehen für die
   Medienwiedergabe zur Verfügung (Konfigurationsliste).

**ROM-Geltung:** Dieses Paket ist derzeit nur für **crDroid 16.0** (Android 16) gedacht.
Unterstützung für andere ROMs ist nicht erprobt.

English version: [README.md](README.md)

---

## Was es ändert

| Patch | Ziel-Repository | Änderung |
|---|---|---|
| `crdroid_build_release_le_ase_read_multi_off.patch` | `build/release` | setzt `com.android.bluetooth.flags.le_ase_read_multiple_variable` für die Release-Konfiguration `bp4a` auf `DISABLED`; keine Quelländerung |
| `crdroid_bluetooth_le_codec_preference_match.patch` | `packages/modules/Bluetooth` | die ASE-Konfigurationsprüfung behandelt nicht gesetzte Vorgabefelder (und Kanalzahl 0) als „beliebig“ und vergleicht die gewünschte Frame-Dauer mit dem Kandidaten |
| `crdroid_bluetooth_le_media_32khz.patch` | `packages/modules/Bluetooth` | hängt acht vorhandene LC3-Senkenkonfigurationen (32 kHz mit 7,5/10 ms, 24 kHz mit 7,5 ms) ans Ende des Media-Szenarios |

Kein Treiber-, Codec- oder Settings-Quellcode wird angefasst. Eine Bedienoberfläche für Codec,
Abtastrate und Frame-Dauer liefert das getrennte Modul [`bluetooth-codec-ui`](../bluetooth-codec-ui/);
privilegierte System-Apps können auch die System-API `BluetoothLeAudio.setCodecConfigPreference` nutzen.

## 1. Verbindung: gesammelte Attributabfragen

Ist das Flag eingeschaltet, senden LE-Audio-Client und Volume Control ATT *Read Multiple Variable
Length* an jede Gegenstelle, die EATT anbietet. Das spart Hin- und Rückläufe und ist eine sinnvolle
Optimierung — solange die Gegenstelle antwortet.

Manche Empfänger bieten EATT an, beantworten genau diese Anfrage aber nie. Der Stack wartet dann auf
die Antwort, läuft nach etwa 30 Sekunden in den Zeitablauf und trennt die Verbindung. Der Zustand
`Connected` wird nie erreicht; LE Audio sieht einfach kaputt aus, während Bluetooth Classic auf
demselben Gerät weiter funktioniert.

Gemessen mit einem FiiO BTR17 (QCC5181) unter crDroid 16.0 auf einem OnePlus 13:

| | Vorher | Nachher |
|---|---|---|
| Gesammelte Abfragen gesendet / beantwortet | 8 / 0 | — |
| Ergebnis | Zeitablauf nach ~30 s, Verbindung getrennt | `STATE_CONNECTED` nach **264 ms** |
| `LeAudioStateMachine` | erreichte `Connected` nie | `Connected` |

Das Flag ist `READ_ONLY`. Am Gerät lässt es sich lesen, aber nicht ändern:

```
$ adb shell aflags list | grep le_ase_read_multiple_variable
com.android.bluetooth.flags.le_ase_read_multiple_variable   enabled - default read-only
```

Der von `bp1a` geerbte Wert ist `ENABLED` / `READ_ONLY`; ändern lässt er sich deshalb nur beim Bauen.
Ein Wert deckt beide Aufrufer ab — den LE-Audio-Client und Volume Control.

## 2. Codec-Vorgabe: die Konfigurationsprüfung

Eine Codec-Vorgabe (zum Beispiel 24 kHz oder 7,5 statt 10 ms) speichert der Stack zwar, doch die
Funktion, die prüft, ob eine ASE-Konfiguration zur Vorgabe passt, lehnte jeden Kandidaten ab:

* sie verlangte, dass jedes Vorgabefeld gesetzt ist, obwohl eine Vorgabe meist nur einige setzt
  (zum Beispiel nur die Abtastrate);
* sie verglich eine Kanalzahl 0 („beliebig“) exakt;
* sie verglich die Frame-Dauer des Kandidaten mit sich selbst statt mit der Vorgabe.

Der Stream blieb deshalb auf der Standardkonfiguration (48 kHz / 10 ms), während die Vorgabe den
neuen Wert meldete. Der Patch behandelt nicht gesetzte Felder und Kanalzahl 0 als „beliebig“ und
vergleicht die gewünschte Frame-Dauer mit dem Kandidaten. Die Prüfungen, dass jede ASE eines
Kandidaten eine Konfiguration hat und die Topologie passt, bleiben unverändert.

## 3. Media-Konfigurationen: 32 kHz und 24 kHz / 7,5 ms

Für Medien wählt der Stack nur aus der Liste des Szenarios `Media`. Diese Liste enthielt keine
32-kHz-Senkenkonfiguration und keine mit 24 kHz / 7,5 ms, obwohl beide im Konfigurationskatalog des
Stacks vorhanden sind und in anderen Szenarien verwendet werden. Eine Vorgabe dafür ließ sich nicht
erfüllen und fiel auf 48 kHz / 10 ms zurück.

Der Patch hängt acht vorhandene Konfigurationen ans Ende der `Media`-Liste — jeweils eine
Stereo-CIS- und zwei Mono-CIS-Varianten:

| Konfiguration | Abtastrate | Frame | Oktette pro Frame |
|---|---|---|---|
| `…Lc3_32_1_Low_Latency` | 32 kHz | 7,5 ms | 60 |
| `…Lc3_32_2_Low_Latency` | 32 kHz | 10 ms | 80 |
| `…Lc3_24_1_Low_Latency` | 24 kHz | 7,5 ms | 45 |

Weil sie am Ende stehen, ändert sich die Standardwahl ohne Vorgabe nicht. Eine einzelne Mono-ASE mit
24 kHz / 7,5 ms hat im Katalog keine Definition und wird nicht ergänzt.

Gemessen am selben Aufbau (LC3, Hardware-Offload, Medienkontext), jeder Schritt mit sauberem Ton:

| Vorgabe | Aktive Stream-Konfiguration | SDU |
|---|---|---:|
| 48 kHz / 10 ms (Standard) | `One-TwoChan-SnkAse-Lc3_48_4_High_Reliability` | 240 |
| 48 kHz / 7,5 ms | `One-TwoChan-SnkAse-Lc3_48_3_High_Reliability` | 180 |
| 24 kHz / 7,5 ms | `One-TwoChan-SnkAse-Lc3_24_1_Low_Latency` | 90 |
| 32 kHz / 7,5 ms | `One-TwoChan-SnkAse-Lc3_32_1_Low_Latency` | 120 |
| 32 kHz / 10 ms | `One-TwoChan-SnkAse-Lc3_32_2_Low_Latency` | 160 |

## Voraussetzungen und Geltungsbereich

* **Prüfen, welche Release-Konfiguration der eigene Build wählt.** Die Flag-Datei liegt im
  Verzeichnis `bp4a`. Ein Build, der eine andere Release-Konfiguration wählt, liest sie nicht. In
  einem LineageOS-artigen Baum kommt der Wert aus `vendor/lineage/vars/aosp_target_release`. Das
  Verzeichnis sammelt seine Werte per Glob, eine weitere Registrierung ist nicht nötig.
* **Ton braucht einen funktionierenden Herstellerpfad.** Ob LE Audio klingt, hängt am Audiopfad des
  Herstellers. Auf Qualcomm-Plattformen muss der LE-Offload-Pfad angemeldet sein, sonst kann die
  Audio-HAL das Gerät `bt-ble` nicht öffnen und es entsteht kein Stream.
* **Empfänger und Audio-DSP entscheiden, was geht.** Die Konfigurationsliste bietet nur Kandidaten
  an; genutzt wird eine Konfiguration nur, wenn der Empfänger sie unterstützt und die Plattform sie
  ausführen kann. Geprüft nur mit dem FiiO BTR17; andere Empfänger brauchen eine eigene Prüfung.
* **Das Flag braucht man vielleicht nicht.** Empfänger, die gesammelte Abfragen korrekt beantworten,
  funktionieren mit eingeschaltetem Flag und behalten die gesparten Hin- und Rückläufe. Die beiden
  Stack-Patches sind vom Flag unabhängig.
* **Nicht geprüft:** der Rücklesewert direkt nach Neustart oder Neuverbindung, 16 kHz, einzelne
  Mono-ASEs und andere Empfänger.

## Prüfen

Nach dem Bauen und Flashen:

```bash
# 1. das Flag muss "disabled" melden
adb shell aflags list | grep le_ase_read_multiple_variable

# 2. Empfänger per LE Audio verbinden und Wiedergabe starten, dann den Stream ansehen
adb shell "dumpsys bluetooth_manager | grep -E 'name=LeAudioStateMachine state=|Current state:|Active config:|Stream config:'"
```

Erwartet: Das Flag meldet `disabled`, `LeAudioStateMachine` erreicht `state=Connected`, und nach
Wahl einer Abtastrate oder Frame-Dauer nennen `Active config` und `Stream config` eine Konfiguration
mit dieser Rate und diesem Frame (zum Beispiel `Lc3_24_1` für 24 kHz / 7,5 ms).

Sind mehrere Quellen mit dem Empfänger gekoppelt, zuerst die anderen trennen. Dual-Mode-Empfänger
halten zwei Verbindungen, und eine zweite Quelle verändert, was der Empfänger meldet und anzeigt.

## Anwenden

```bash
git -C build/release apply --check le-audio-fixes/patches/crdroid_build_release_le_ase_read_multi_off.patch
git -C build/release apply       le-audio-fixes/patches/crdroid_build_release_le_ase_read_multi_off.patch
git -C packages/modules/Bluetooth apply --check le-audio-fixes/patches/crdroid_bluetooth_le_codec_preference_match.patch
git -C packages/modules/Bluetooth apply       le-audio-fixes/patches/crdroid_bluetooth_le_codec_preference_match.patch
git -C packages/modules/Bluetooth apply --check le-audio-fixes/patches/crdroid_bluetooth_le_media_32khz.patch
git -C packages/modules/Bluetooth apply       le-audio-fixes/patches/crdroid_bluetooth_le_media_32khz.patch
```

Die Pfade in den Patches sind relativ zu ihrem Ziel-Repository, nicht zur Wurzel des Android-Baums.
Das Installationsskript `apply-patches.sh` macht dasselbe mit den Prüfungen zusammen.

Upstream-Verweise, Lizenzfragen und die Anwendungs-Prüfliste stehen in [NOTICE](NOTICE).
