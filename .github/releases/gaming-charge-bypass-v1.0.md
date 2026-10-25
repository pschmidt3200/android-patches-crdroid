# Gaming Charge Bypass v1.0

> **Superseded.** This is the final crDroid 16.0 edition; for crDroid 17.0 use [Gaming Charge Bypass v2.0](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/gaming-charge-bypass-v2.0).
> On a crDroid 16.0 tree this release stays valid (branch `16.0`). Deutsch: Letzte crDroid-16.0-Fassung; für crDroid 17.0 gilt Gaming Charge Bypass v2.0, für 16.0-Bäume bleibt diese Fassung gültig.

First public module release for **crDroid 16.0 / Android 16**. Charging is paused
while a game is in the foreground, so the battery is not charged and discharged at
the same time during a long session. On game exit the previous charging
configuration is written back exactly as it was found.

## Included changes

* `frameworks/base` — `GameStateDispatcher` engages the charge pause on game start
  and restores the stored state when the game leaves the foreground.
* `packages/apps/GameSpace` — the threshold option in the in-game panel: **battery
  level at game start**, or a fixed value between 70 and 100 %.

The two patches work as a pair; applying one alone leaves either an option without
effect or an effect without an option. The pause uses the LineageOS charging-control
feature the tree already contains — the same setter a user reaches through
*Settings → Battery → Charging control*. No kernel node is written directly, no
charging driver is modified and no vendor interface is added. If a write fails, the
stored state is kept and nothing is left half-applied.

**Why the threshold starts at 70:** the LineageOS provider validates
`charging_control_charging_limit` and rejects anything below 70, so lower values
cannot work on any device. For the same reason the "battery level at game start"
option raises a start level below 70 to 70.

Read the [module instructions](https://github.com/pschmidt3200/android-patches-crdroid/tree/gaming-charge-bypass-v1.0/gaming-charge-bypass)
before choosing this on a build.

## Source baselines

| Target repository | NOTICE reference commit |
|---|---|
| `frameworks/base` | `68d3d80589e4cc8dd34c470db3aa9c027f610674` |
| `packages/apps/GameSpace` | `2fecfaa6e963a288048dceedc6520f12b0116cd2` |

```bash
git switch --detach gaming-charge-bypass-v1.0
bash gaming-charge-bypass/apply-patches.sh --check /path/to/crdroid
```

## Verified on a device, and what was not

Verified on a OnePlus 13 running crDroid 16.0:

| Check | Result |
|---|---|
| threshold 70 % | engaged and applied, eight cycles across four games |
| charge stop at threshold | battery status 2 (charging) → 4 (not charging), current −2976 mA → 0 mA at exactly level 70 |
| restore on game exit | eight cycles, always to the stored original state |
| restore after reboot with a game in the foreground | stored state replayed and cleared 82 s after boot |
| rapid game switching | stable down to 0.5 s between cycles |
| no game running | charging is never touched |
| start level below the minimum | at 69 % battery the log reports the threshold as 70, not 69 |

**Not verified on a device: the thresholds 80, 90 and 100 %.** That the LineageOS
provider accepts those values was measured separately, which is not the same as a
device test of the GameSpace path.

## Validation

Publication checks metadata and format, installer behaviour, and real source
application **and reversal** at the NOTICE commits and against the current
Android 16 branches. A ROM build and device acceptance of this public module
version remain the user's own step.

## Deutsch

Erste öffentliche V1. Der Ladevorgang pausiert, solange ein Spiel im Vordergrund
ist; beim Verlassen wird die vorher gespeicherte Ladekonfiguration unverändert
zurückgeschrieben. Die Schwelle ist im GameSpace-Panel wählbar — Akkustand beim
Spielstart oder ein fester Wert zwischen 70 und 100 %. Unter 70 lehnt der
LineageOS-Validator ab, deshalb beginnt die Auswahl dort. **Am Gerät belegt ist
die Schwelle 70** (acht Zyklen über vier Spiele, Ladestopp bei genau 70, Rückgabe
nach Spielende und nach Neustart); 80, 90 und 100 % sind **nicht** am Gerät
geprüft. Kein Kernel-Node, kein Ladetreiber, keine Vendor-Schnittstelle.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
