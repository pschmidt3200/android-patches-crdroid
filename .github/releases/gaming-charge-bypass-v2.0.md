# Gaming Charge Bypass v2.0

First edition for **crDroid 17.0 / Android 17**. Version 2.x is the crDroid 17.0 line; the final crDroid 16.0 edition is [`gaming-charge-bypass-v1.0`](https://github.com/pschmidt3200/android-patches-crdroid/releases/tag/gaming-charge-bypass-v1.0) on branch [`16.0`](https://github.com/pschmidt3200/android-patches-crdroid/tree/16.0).

Charging pauses while a game is in the foreground, so the battery is not charged and discharged at the same time during a long session; on game exit the previous charging configuration is written back. The threshold is chosen in the GameSpace in-game panel: **battery level at game start**, or a fixed value between 70 and 100 %.

## Changes from the crDroid 16.0 edition

* The framework part is ported to Android 17 (GameSpace is started by the framework).
* The GameSpace threshold option is unchanged.

## Status on crDroid 17.0

**Device-verified on crDroid 17.0.** On 2026-10-20 the maintainer accepted the module on a OnePlus 13: with *battery level at game start* (66 %, raised to 70 %) charging stopped at 70 %; with a fixed limit of 90 % it continued past the 80 % limit of the existing charging-control setting and stopped at 90 %. Moving the game to the background and back kept the pause. In both runs the previous charging settings were written back on game exit and charging resumed.

The module is also part of the maintainer's crDroid 17.0 ROM build of 2026-10-22, made from this repository at commit `4bdecab`.

## Source baselines

Read the [module instructions at this tag](https://github.com/pschmidt3200/android-patches-crdroid/tree/gaming-charge-bypass-v2.0/gaming-charge-bypass) before using it on a build.

| Target repository | NOTICE reference commit |
|---|---|
| `frameworks/base` | `c2382c14b024f5701071d31d9cc8fe1401dc9a88` |
| `packages/apps/GameSpace` | `6ee68e38389c30454e5626aa9a048d2617542382` |

```bash
git switch --detach gaming-charge-bypass-v2.0
bash gaming-charge-bypass/apply-patches.sh --check /path/to/crdroid
```

Publication requires installer tests and real source application/reversal at these commits and the current `17.0` branches. Device results concern the documented reference setup; other devices, firmware and source revisions need their own acceptance.

## Deutsch

Erste Fassung für crDroid 17.0, am Gerät abgenommen (20.10.2026, OnePlus 13): Grenze „Spielstart“ und feste 90 % halten, beim Spielende werden die vorherigen Ladeeinstellungen zurückgeschrieben. Teil des 17.0-Builds vom 22.10.2026.

Apache License 2.0; preserve LICENSE, NOTICE and upstream file notices.
