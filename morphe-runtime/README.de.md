# Morphe-Runtime-Kompatibilität für crDroid

[English](README.md)

Optionaler Quellpatch für **crDroid 17.0 (Android 17)**. Der ROM-Filter in
libc kann `org.lineageos.platform-res.apk` vor Morphes separatem ART-Patcher
verstecken, obwohl die Datei existiert. Morphe erhält eine gezielte
Prozessausnahme wie der bereits ausgenommene LineageOS-Updater.

| Patch | Zielrepo | Änderung |
|---|---|---|
| [crdroid_bionic_morphe_runtime.patch](patches/crdroid_bionic_morphe_runtime.patch) | `bionic` | `app.morphe.manager` in die Ausnahmeliste aufnehmen; frühe Entscheidungen unter dem vorläufigen Launcher-Namen noch nicht speichern. |

Der bestehende Parser erfasst auch `app.morphe.manager:Patcher`.
Die drei Launcher `/system/bin/app_process`, `/system/bin/app_process32`
und `/system/bin/app_process64` bleiben gefiltert. Erst nach der Umbenennung
wird das Ergebnis normal zwischengespeichert. Andere Apps, ähnlich benannte
Pakete, Updater und Zygote sind mit Positiv-/Negativproben abgedeckt.
Die Ausnahme prüft den Prozessnamen, keine Paketsignatur.

> **crDroid-17.0-Fassung: quellgeprüft, noch nicht auf dem Gerät getestet.** Diese Patches
> zielen auf crDroid 17.0 und lassen sich an den [`NOTICE`](NOTICE)-Referenzcommits sauber
> anwenden und zurücknehmen. ROM-Build und Geräteprüfung unter 17.0 stehen aus; der unten
> beschriebene Host-Test lief gegen den 16.0-Quellstand. Die 16.0-Fassung bleibt auf dem Branch
> [`16.0`](https://github.com/pschmidt3200/android-patches-crdroid/tree/16.0/morphe-runtime).

## Anwenden und zurücknehmen

Nur bei angehaltenem Build auf einem kompatiblen, sauberen Quellbaum
anwenden. Referenzstand und Herkunft stehen in [NOTICE](NOTICE).
Aus dem Wurzelverzeichnis dieses Patch-Repos:

```bash
bash morphe-runtime/apply-patches.sh --check /pfad/zu/crdroid
bash morphe-runtime/apply-patches.sh /pfad/zu/crdroid
bash morphe-runtime/apply-patches.sh --check --reverse /pfad/zu/crdroid
bash morphe-runtime/apply-patches.sh --reverse /pfad/zu/crdroid
```

Danach Änderungen prüfen, ROM neu bauen und normal installieren.
Kein flashbares ZIP und kein Schalter für ein bereits installiertes ROM.
Auch die Rücknahme braucht einen neuen ROM-Build und dessen Installation.
Den Patch nicht über zwei Patchmanager doppelt einbinden.

## Prüfung und Grenzen

Der echte C++-Filter wurde auf dem Host mit kontrollierter UID, PID und
Prozesskennung kompiliert: **43 Prüfungen, null Fehler**. Die ungepatchte
Quelle scheitert an neun Prüfungen; nur der Ausnahmelisteneintrag lässt
noch die drei späten Umbenennungen scheitern. Die Probe startet kein ART.
Neuer ROM-Build und Abnahme am Gerät stehen aus.

Nach Installation Morphes **Process runtime** einschalten und den
fehlgeschlagenen Patchvorgang wiederholen. Das Laden der LineageOS-
Framework-Ressource darf nicht mehr scheitern. Der getrennte ART-Fehler
`Could not find contiguous low-memory space` wird hier nicht behoben.

Referenz: [Morphe-Prozessstart](https://github.com/MorpheApp/morphe-manager/blob/da8545c92c94b83e23adf7b573b46b282fa2b062/app/src/main/java/app/morphe/manager/patcher/runtime/ProcessRuntime.kt#L314).
Lizenz: [LICENSE](LICENSE). Bei einem entsprechenden Upstream-Fix den
Zusatz erst nach erneuter Quellprüfung entfernen.
