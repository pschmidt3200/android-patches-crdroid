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
Kernelindex). Die crDroid-16.0-Fassung bleibt getrennt eingefroren. Andere Quellstände
benötigen eigene Prüfung.

> **17.0-Update vom 20.10.2026:** Auf Upstream `4a4cb1be85a4`
> im Branch `gki-android15-6.6` neu aufgesetzt. Anwendung/Ruecknahme am Pin und
> aktuellen Branch bestehen. Hinzugefuegte/entfernte Kernelzeilen bleiben exakt
> upstream; nur Kontext und Patch-Metadaten aendern sich. Neuer Kernel-Build und
> Geraeteabnahme stehen aus. Die Geraetemessungen unten stammen aus crDroid 16.0.
> Die eingefrorene 16.0-Fassung bleibt auf Branch
> [`16.0`](https://github.com/pschmidt3200/android-patches-crdroid/tree/16.0/susfs-core).

## Anwendung in zwei Schritten

Der Modulinstaller verändert **eine Upstream-Patchdatei**, keine Kernelquelle.
Als Ziel braucht er einen eigenen Git-Checkout unter `external/susfs4ksu` im
crDroid-Baum. Falls noch nicht vorhanden, den genauen Upstream-Stand vorbereiten:

```bash
cd /pfad/zu/crdroid
git clone --branch gki-android15-6.6 https://gitlab.com/simonpunk/susfs4ksu.git external/susfs4ksu
git -C external/susfs4ksu checkout --detach 4a4cb1be85a4694372d3efb9420de69982eac29a
```

In der Patchsammlung alle Moduldateien aus derselben Fassung verwenden:

```bash
bash susfs-core/apply-patches.sh --check /pfad/zu/crdroid
bash susfs-core/apply-patches.sh /pfad/zu/crdroid
sha256sum /pfad/zu/crdroid/external/susfs4ksu/kernel_patches/50_add_susfs_in_gki-android15-6.6.patch
```

Erwartete SHA256 der korrigierten vollständigen Upstream-Patchdatei:
`db6de46a32533e3f5cf3d32d139977ce2f0e570b9d5170095615617af52557d4`.
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
und Rücknahme auf dem Upstream-Referenzstand und dem aktuellen Branch
`gki-android15-6.6` sowie die exakte
Ergebnisprüfsumme. Die entstandene vollständige
Upstream-Patchdatei wird separat mit BBRv3 im isolierten Referenz-Kernelindex geprüft.
**Dokumentierte Kernel- und Geräteabnahme:** Auf dem Referenzgerät **OnePlus 13**
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
