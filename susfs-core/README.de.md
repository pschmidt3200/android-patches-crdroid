# SUSFS-Core-Kontextkorrekturen für crDroid sm8750

**Enthalten ist ausschließlich unsere Wartungsänderung.**
`patches/susfs-core-context.patch` korrigiert Kontext, Hunk-Positionen und
Index-Metadaten der originalen Upstream-Patchdatei. Der vollständige SUSFS-Core
wird nicht mitgeliefert. Seine hinzugefügten/entfernten Kernelzeilen bleiben
unverändert; neue SUSFS-Funktionen wurden dabei nicht entwickelt.

Der Kontext enthält jetzt `vma_data_pages()` statt des veralteten `vma_pages()`.
Die korrigierte Upstream-Patchdatei zielt auf `kernel/oneplus/sm8750`, Branch
`16.0`, Commit `b69d2cc667dd0a57adb78b54c9a3453f5c5a5b35` (Android 15 / Linux 6.6)
für crDroid 16.0. Andere Quellstände benötigen eigene Prüfung.

## Anwendung in zwei Schritten

Der Modulinstaller verändert **eine Upstream-Patchdatei**, keine Kernelquelle.
Als Ziel braucht er einen eigenen Git-Checkout unter `external/susfs4ksu` im
crDroid-Baum. Falls noch nicht vorhanden, den genauen Upstream-Stand vorbereiten:

```bash
cd /pfad/zu/crdroid
git clone --branch gki-android15-6.6 https://gitlab.com/simonpunk/susfs4ksu.git external/susfs4ksu
git -C external/susfs4ksu checkout --detach a0f9c59e2243f8a5db955f4ad1686d5e0ad26e1a
```

In der Patchsammlung alle Moduldateien aus derselben Fassung verwenden:

```bash
bash susfs-core/apply-patches.sh --check /pfad/zu/crdroid
bash susfs-core/apply-patches.sh /pfad/zu/crdroid
sha256sum /pfad/zu/crdroid/external/susfs4ksu/kernel_patches/50_add_susfs_in_gki-android15-6.6.patch
```

Erwartete SHA256 der korrigierten vollständigen Upstream-Patchdatei:
`17d0e86e625afab0bbe2a3e3a4f46d326aeec641930d8a922bd747e5955b9c4a`.
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
und Rücknahme auf dem Upstream-Referenzstand sowie aktuellem Branch
`gki-android15-6.6` und die exakte Ergebnisprüfsumme. Die entstandene vollständige
Upstream-Patchdatei wird separat mit BBRv3 im isolierten Referenz-Kernelindex geprüft.
**Neuer Kernel-/ROM-Build und Geräteabnahme bleiben offen.** Es ist kein
vollständiger SUSFS-Installer und keine Zusage, dass Apps ein verändertes System
akzeptieren. Modulprüfungen laufen bei jedem Push über GitHub Actions. Produktive Patches bleiben unverändert;
hier wird ausschließlich unser Korrekturdelta hochgeladen.

## Lizenzabgrenzung

[LICENSE](LICENSE) erhält den originalen **GPL-Version-3**-Text des gepinnten
Upstream-Stands. Eigene Doku, Metadaten und Installer verwenden
[Apache 2.0](LICENSE-APACHE-2.0); Upstream-Material behält seine Bedingungen.
Der Zielkernel nennt GPL-2.0-only. Die GPL3/GPL2-Abgrenzung für einen kombinierten
Kernel ist ungeklärt; dieser Quellpatch belegt keine Lizenzkompatibilität oder
Rechtsfreigabe. Vollständiger Core und Binärdateien werden nicht mitgeliefert.
