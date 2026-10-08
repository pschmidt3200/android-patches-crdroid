# Gaming Charge Bypass

Pauses charging while a game is running, so the battery is not charged and
discharged at the same time during long sessions. When the game exits, the
previous charging configuration is restored exactly as it was.

The threshold is user-visible in the GameSpace in-game panel:
**battery level at game start**, or a fixed value between 70 and 100 %.

## What the two patches do

| Patch | Repository | Effect |
|---|---|---|
| `crdroid_framework_gaming_bypass.patch` | `frameworks/base` | `GameStateDispatcher` engages the charge pause on game start and restores the stored state on exit |
| `crdroid_gamespace_charging_limit.patch` | `packages/apps/GameSpace` | the threshold option in the in-game panel |

They work as a pair. Applying only one leaves either an option without effect or
an effect without an option.

## How it works

The charge pause uses the LineageOS charging-control feature that the tree
already contains — the same setter a user reaches through
*Settings → Battery → Charging control*. Before changing anything, the current
mode, limit and enabled flag are stored; on game exit they are written back and
the stored copy is cleared. No kernel node is written directly, no charging
driver is touched, and no vendor interface is added.

If a write fails, the stored state is kept and nothing is left half-applied.

## Why the threshold starts at 70

The LineageOS provider validates `charging_control_charging_limit` and rejects
values below 70. Lower values therefore cannot work, regardless of device or
battery level, and the option does not offer them. For the same reason, the
"battery level at game start" setting raises a start level below 70 to 70 —
otherwise the default case would fail for every user starting a game with a
battery below 70 %.

## Verified on a device, and what was not

Verified on a OnePlus 13 (dodge), crDroid 16.0:

* threshold 70 % engaged and applied, eight cycles across four games
* charge stop at the threshold: status 2 (charging) → 4 (not charging),
  current −2976 mA → 0 mA at exactly level 70
* restore on game exit, eight cycles, always to the stored original state
* restore after a reboot while a game was in the foreground, 82 s after boot
* stable with 0.5 s between cycles
* with no game running, charging is never touched

**Not verified on a device:** the thresholds 80, 90 and 100 %. That the provider
accepts those values was measured separately, which is not the same as a device
test.

## Requirements

crDroid 16.0 (Android 16). Other ROMs are untested. See `NOTICE` for the exact
upstream tree states the diffs were generated against.
