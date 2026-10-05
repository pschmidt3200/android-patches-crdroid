# Bluetooth Codec UI v1.2

LE Audio release for **crDroid 16.0 / Android 16**.
Reference platform: **OnePlus 13** (`dodge`, CPH2653) with **FiiO BTR17** (LC3 over LE Audio; aptX Adaptive, AAC, SBC over A2DP).

## Changes from v1.1

* **LE Audio groups:** the *Audio codec* entry on the Connected devices page now also covers the
  active LE Audio group. It shows codec, sample rate, frame duration and octets per frame, read
  back from the stack.
* **Own rows for LE Audio parameters:** *Sample rate* and *Frame duration* (7.5 / 10 ms) can be
  chosen in their own rows where the device offers alternatives. An *Octets per frame* row appears
  only when the stack reports valid limits.
* **Validated requests:** LE Audio choices are checked against complete selectable capabilities of
  the device and requested for the active group; the microphone direction stays automatic. The
  entry always shows the configuration read back from the stack, not the tapped value.
* **Codec list:** for LE Audio, the *Audio codec* entry opens the codec list directly, as for A2DP.

Whether an LE Audio choice reaches the stream is decided by the Bluetooth stack. On crDroid 16.0
that needs the [`le-audio-fixes`](https://github.com/pschmidt3200/android-patches-crdroid/tree/le-audio-fixes-v1.0/le-audio-fixes)
module.

## Requirements and source baselines

No ROM image, binaries or vendor firmware are included. Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/bluetooth-codec-ui-v1.2/bluetooth-codec-ui).

| Target repository | NOTICE reference commit |
|---|---|
| `frameworks/base` | `a7b0e5e188fb72a566328bfed0e0412ddb7850e2` |
| `packages/apps/Settings` | `62faa70985307e4e5fca0c7c838f11dba0b2c4ab` |

```bash
git switch --detach bluetooth-codec-ui-v1.2
bash bluetooth-codec-ui/apply-patches.sh --check /path/to/crdroid
```

## Deutsch

LE-Audio-Fassung: Der Eintrag *Audio-Codec* auf „Verbundene Geräte“ deckt jetzt auch die aktive
LE-Audio-Gruppe ab und zeigt Codec, Abtastrate, Frame-Dauer und Oktette pro Frame, wie der Stack sie
zurückmeldet. Abtastrate und Frame-Dauer (7,5 / 10 ms) haben eigene Zeilen; die Auswahl wird gegen
die vollständigen Fähigkeiten des Geräts geprüft. Unter crDroid 16.0 braucht die Umschaltung im
Stream das Modul `le-audio-fixes`.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
