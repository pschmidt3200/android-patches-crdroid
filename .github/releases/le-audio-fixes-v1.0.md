# LE Audio Fixes v1.0

Initial release for **crDroid 16.0 / Android 16**.
Reference platform: **OnePlus 13** (`dodge`, CPH2653) with **FiiO BTR17** (LC3 over LE Audio, hardware offload).

## Contents

* **Connection:** `com.android.bluetooth.flags.le_ase_read_multiple_variable` is set to `DISABLED`
  for the release configuration `bp4a`. Receivers that advertise EATT but never answer ATT *Read
  Multiple Variable Length* now connect (measured: `STATE_CONNECTED` after 264 ms instead of a
  30-second timeout).
* **Codec preference:** the LE Audio configuration matcher treats preference fields that are not
  set, and a channel count of 0, as "any", and compares the requested frame duration with the
  candidate. A chosen sample rate or frame duration now reaches the stream.
* **Media configurations:** eight existing LC3 sink configurations — 32 kHz at 7.5 and 10 ms,
  24 kHz at 7.5 ms — are appended to the `Media` scenario. The default choice without a
  preference is unchanged.

Verified on the reference platform, each with clean audio: 24 kHz / 7.5 ms (`Lc3_24_1`),
32 kHz / 7.5 ms (`Lc3_32_1`), 32 kHz / 10 ms (`Lc3_32_2`), and 48 kHz at 7.5 and 10 ms.
Not verified: read-back after a reboot or reconnection, 16 kHz, single mono ASEs, other receivers.

## Requirements and source baselines

No ROM image, binaries or vendor firmware are included. LE Audio sound also needs a working vendor
LE offload path. Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/le-audio-fixes-v1.0/le-audio-fixes).

| Target repository | NOTICE reference commit |
|---|---|
| `build/release` | `d76088e515490325b6edd276ef167449fd71805a` |
| `packages/modules/Bluetooth` | `c575db642364a8e3e2f9878d2fdd55dc4451230e` |

```bash
git switch --detach le-audio-fixes-v1.0
bash le-audio-fixes/apply-patches.sh --check /path/to/crdroid
```

## Deutsch

Erstveröffentlichung: Ein Flagwert zur Bauzeit lässt LE-Audio-Empfänger verbinden, die die
gesammelte Attributabfrage nie beantworten. Eine korrigierte Konfigurationsprüfung bringt eine
gewählte Abtastrate oder Frame-Dauer in den Stream, und acht vorhandene LC3-Konfigurationen
(32 kHz mit 7,5/10 ms, 24 kHz mit 7,5 ms) stehen für Medien bereit.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
