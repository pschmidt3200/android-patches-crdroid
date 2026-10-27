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

> **crDroid-17.0-Fassung: am Gerät geprüft.** Diese Patches zielen auf crDroid 17.0 und lassen
> sich an den [`NOTICE`](NOTICE)-Referenzcommits sauber anwenden und zurücknehmen. Am 27.10.2026
> wurde Morphes Prozess-Laufzeit auf einem OnePlus 13 mit dem 17.0-Build des Maintainers vom
> 25.10.2026, gebaut aus diesem Repository auf Stand `4bdecab`, geprüft; siehe *Prüfung und
> Grenzen*. Die 16.0-Fassung bleibt auf dem Branch
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

Nach Installation Morphes **Process runtime** einschalten und den
fehlgeschlagenen Patchvorgang wiederholen. Das Laden der LineageOS-
Framework-Ressource darf nicht mehr scheitern. Der getrennte ART-Fehler
`Could not find contiguous low-memory space` wird hier nicht behoben.

**Geräteprüfung unter crDroid 17.0 (27.10.2026):** OnePlus 13, Build vom 25.10.2026. Die
`libc.so` des Geräts enthält die Ausnahme für `app.morphe.manager` neben dem LineageOS-Updater.
Morphe Manager ist mit eingeschalteter **Process runtime** installiert, und der Maintainer
meldet, dass der Patcher sauber durchläuft; das Geräteprotokoll zeigt keine Morphe-Fehler.

Referenz: [Morphe-Prozessstart](https://github.com/MorpheApp/morphe-manager/blob/da8545c92c94b83e23adf7b573b46b282fa2b062/app/src/main/java/app/morphe/manager/patcher/runtime/ProcessRuntime.kt#L314).
Lizenz: [LICENSE](LICENSE). Bei einem entsprechenden Upstream-Fix den
Zusatz erst nach erneuter Quellprüfung entfernen.
