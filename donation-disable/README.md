# Disable donation requests in crDroid

[Deutsch](README.de.md)

An optional source patch module for **crDroid 16.0 (Android 16)**.
I created this because I personally dislike this form of donation request
inside my ROM. It is not a statement against donations in general.

The module removes crDroid's donation prompts, donation page and donation
links from Settings. It preserves maintainer names and their OTA lookup,
project credits, copyright notices and unrelated About entries. Telemetry
and personal branding are separate concerns and are not changed here.

## Changes

Apply **all three patches together** for the complete result; partial use
leaves entry points behind. The two Android source repositories are required.

| Patch | Target repository | Effect |
|---|---|---|
| [donation_components.patch](patches/donation_components.patch) | `packages/apps/crDroidSettings` | Deletes `DonateActivity` and its donation-progress network request. Replaces the reminder receiver with cleanup of existing alarms, notifications and its channel; it never schedules or displays a new reminder. |
| [donation_about.patch](patches/donation_about.patch) | `packages/apps/crDroidSettings` | Removes the donation preference from About and clears the default maintainer donation URL. |
| [donation_settings.patch](patches/donation_settings.patch) | `packages/apps/Settings` | Removes the donation activity registration, disables the donation shortcut on repeated crDroid-version taps in both Settings implementations, and removes overlay/OTA donation-link handling from the maintainer preference. Maintainer names remain visible and copyable. |

The receiver remains registered for boot, user unlock and old reminder
broadcasts **only to clear reminders from earlier builds**. It does not
create a pending alarm when none exists. Unused upstream translations,
layouts and icons remain in the resource tree; no reachable donation UI uses
them. Website/community/sponsor credits remain. Content on external websites
is outside this module's scope.

## Apply and undo

Use a clean crDroid source tree with no build running. Reference commits are
in [NOTICE](NOTICE). Remove or reconcile an older donation modification in
the same files before applying; the helper refuses conflicting or already
applied patches. It simulates the entire series on copies before writing.

From this patch repository's root:

```bash
bash donation-disable/apply-patches.sh --check /path/to/crdroid
bash donation-disable/apply-patches.sh /path/to/crdroid
bash donation-disable/apply-patches.sh --check --reverse /path/to/crdroid
bash donation-disable/apply-patches.sh --reverse /path/to/crdroid
```

Review the resulting diffs, then build and install the ROM normally.
This is a source patch, not a flashable ZIP or a toggle in an installed ROM.
Reboot after installing the build so the cleanup receiver can remove old
reminders. Reversing restores the original donation feature in source;
another ROM build and installation are required to restore it on the device.

## Validation and limits

Format, helper failure handling and source apply/reverse are checked against
the [NOTICE](NOTICE) commits and the current crDroid `16.0` branch:

```bash
bash .github/scripts/check-modules.sh
bash .github/scripts/test-apply-script.sh donation-disable
bash .github/scripts/check-reference.sh donation-disable
bash .github/scripts/check-reference.sh --branch 16.0 donation-disable
```

Source validation is complete:
- 34 of 34 helper tests (`test-apply-script.sh`) passed cleanly.
- Clean apply and reverse (3/3 patches) on reference commits and crDroid `16.0` HEAD.
- Successful dry-run simulation against local crDroid source trees.

**ROM build and device acceptance:** On the reference device **OnePlus 13 (`dodge`, CPH2653)**,
upstream donation components are still active in the current ROM build because this module
has not yet been compiled into the running image. Device acceptance requires applying the
patches before the next ROM build. After installing, check Settings/About, repeated
crDroid-version taps, maintainer name/copying, and the absence of reminders after boot/unlock.
License and upstream attribution: [LICENSE](LICENSE), [NOTICE](NOTICE).

