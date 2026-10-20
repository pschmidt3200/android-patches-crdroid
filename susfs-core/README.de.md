# SUSFS-Core-Kontextkorrekturen für crDroid sm8750

**Enthalten ist ausschließlich unsere Wartungsänderung.**
`patches/susfs-core-context.patch` korrigiert Kontext, Hunk-Positionen und
Index-Metadaten der originalen Upstream-Patchdatei. Der vollständige SUSFS-Core
wird nicht mitgeliefert. Seine hinzugefügten/entfernten Kernelzeilen bleiben
unverändert; neue SUSFS-Funktionen wurden dabei nicht entwickelt.

Der Kontext enthält jetzt `vma_data_pages()` statt des veralteten `vma_pages()`.
Die korrigierte Upstream-Patchdatei zielt auf `kernel/oneplus/sm8750`, Branch
`17.0`, Commit `48baf0c723f8d6d1efa4db9d2cb5ad6df83ab976` (Android 15 / Linux 6.6)
für crDroid 17.0, allein und nach den `bbrv3`-Patches (geprüft am 20.10.2026 im isolierten
Kernelindex). Auf den crDroid-16.0-Commit `b69d2cc667dd` passte sie ebenso. Andere Quellstände
benötigen eigene Prüfung.

> **crDroid 17.0: quellgeprüft, noch nicht auf dem Gerät getestet.** Die Kernel- und Geräteabnahme
> unten stammt vom crDroid-16.0-Kernel. Der SUSFS-Upstream-Branch `gki-android15-6.6` wurde am
> 18./19.10.2026 umgebaut; diese Fassung zielt weiter auf die festgelegte Revision `2d11d711de80`
> und passt nicht auf den aktuellen Branch-Stand. Die 16.0-Fassung bleibt auf dem Branch
> [`16.0`](https://github.com/pschmidt3200/android-patches-crdroid/tree/16.0/susfs-core).

## Anwendung in zwei Schritten

Der Modulinstaller verändert **eine Upstream-Patchdatei**, keine Kernelquelle.
Als Ziel braucht er einen eigenen Git-Checkout unter `external/susfs4ksu` im
crDroid-Baum. Falls noch nicht vorhanden, den genauen Upstream-Stand vorbereiten:

```bash
cd /pfad/zu/crdroid
git clone --branch gki-android15-6.6 https://gitlab.com/simonpunk/susfs4ksu.git external/susfs4ksu
git -C external/susfs4ksu checkout --detach 2d11d711de80f0f749b3055f8da8f7b9682454e4
```

In der Patchsammlung alle Moduldateien aus derselben Fassung verwenden:

```bash
bash susfs-core/apply-patches.sh --check /pfad/zu/crdroid
bash susfs-core/apply-patches.sh /pfad/zu/crdroid
sha256sum /pfad/zu/crdroid/external/susfs4ksu/kernel_patches/50_add_susfs_in_gki-android15-6.6.patch
```

Erwartete SHA256 der korrigierten vollständigen Upstream-Patchdatei:
`e4a8d393105611dd09d1aa8d74907ea3611fe0e2b7c34fa08a694694aa127433`.
[NOTICE](NOTICE) nennt Originalhash, Quellen und Autoren.
Ein bereits veränderter Checkout wird standardmäßig abgelehnt.
`--check --reverse` und danach `--reverse` nehmen nur diese Patchdatei-Korrektur
zurück; eine separate Anwendung im Kernel wird damit nicht rückgängig gemacht.

Danach die korrigierte Upstream-Patchdatei in der vorhandenen SUSFS-/KernelSU-
Integration nutzen und zunächst `git apply --check` im Zielkernel prüfen.
Dieses Modul installiert weder `fs/susfs.c`, `include/linux/susfs.h`,
`include/linux/susfs_def.h`, KernelSU-Hooks, Konfiguration noch Userspace-Werkzeuge.
Passende Komponenten separat vom gepinnten Upstream beziehen und dessen
Anleitung abgleichen. Eigene/ältere Hooks können kollidieren. Die tatsächliche
SUSFS-Version `v2.3.0` und WildKernels-Fixpaket-Version `v2.2.0` sind unabhängig.

## Prüfstatus und Grenzen

Lokal geprüft werden Modulstruktur, eigenständiger Installer, reale Anwendung
und Rücknahme auf dem Upstream-Referenzstand (der aktuelle Stand des Branches
`gki-android15-6.6` passt seit dessen Umbau am 18./19.10.2026 nicht mehr) und die exakte
Ergebnisprüfsumme. Die entstandene vollständige
Upstream-Patchdatei wird separat mit BBRv3 im isolierten Referenz-Kernelindex geprüft.
**Dokumentierte Kernel- und Geräteabnahme:** Auf dem Referenzgerät **OnePlus 13 (`dodge`, CPH2653)**
unter Linux 6.6 (Build `Sat Oct 3 23:45:41 CEST 2026`) live verifiziert und abgenommen:
SUSFS `v2.3.0` (GKI) ist im Kernel initialisiert (`susfs is initialized! version: v2.3.0`), KSU-Integration
und Userspace-Werkzeuge (`/data/adb/ksu/bin/susfs`) sind aktiv und alle Kernelfeatures (`SUS_PATH`,
`SUS_MOUNT`, `SUS_KSTAT`, `SPOOF_UNAME`, `HIDE_KSU_SUSFS_SYMBOLS`, `OPEN_REDIRECT`, `SUS_MAP`) aktiv.
Modulprüfungen laufen bei jedem Push über GitHub Actions.


## Lizenzabgrenzung

[LICENSE](LICENSE) erhält den originalen **GPL-Version-3**-Text des gepinnten
Upstream-Stands. Eigene Doku, Metadaten und Installer verwenden
[Apache 2.0](LICENSE-APACHE-2.0); Upstream-Material behält seine Bedingungen.
Der Zielkernel nennt GPL-2.0-only. Die GPL3/GPL2-Abgrenzung für einen kombinierten
Kernel ist ungeklärt; dieser Quellpatch belegt keine Lizenzkompatibilität oder
Rechtsfreigabe. Vollständiger Core und Binärdateien werden nicht mitgeliefert.
