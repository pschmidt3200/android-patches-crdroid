# BBRv3 für crDroid sm8750

Gepflegter TCP-BBRv3-Quellpatch für **crDroid 16.0** mit dessen gemeinsamem
OnePlus-`sm8750`-Kernel auf Android 15 / Linux 6.6. ROM-Version und
Android-Generation des Kernels unterscheiden sich; andere Kernel sind ungeprüft.

`patches/bbrv3-android15-6.6.patch` ergänzt den BBRv3-Congestion-Controller
und seine TCP-Anbindung in 13 Kerneldateien. Der gepinnte WildKernels-Backport
wurde auf den aktuellen Quellstand neu basiert, ohne Algorithmusänderung.
Der separate Zusatzpatch `patches/bbrv3-default-android15-6.6.patch` baut BBRv3
fest ein und wählt in `gki_defconfig` den TCP-Standard `bbr3`.
Der Installer wendet zuerst den Core und danach den Zusatzpatch an.
BBRv1 (`bbr`) und die anderen Algorithmen bleiben verfügbar.

## Voraussetzungen und Anwendung

* Ziel: `kernel/oneplus/sm8750`, Branch `16.0`, Referenz
  `b69d2cc667dd0a57adb78b54c9a3453f5c5a5b35`.
* Referenzhardware: OnePlus 13 / Pad 3 mit diesem gemeinsamen Kernel.
  Andere Kernelbäume und Geräte benötigen eigene Prüfungen.
* Bash und Git; alle Moduldateien aus derselben Fassung verwenden.
  Frühere BBR-Änderungen vorher abgleichen.

```bash
bash bbrv3/apply-patches.sh --check /pfad/zu/crdroid
bash bbrv3/apply-patches.sh /pfad/zu/crdroid
# Quelländerung zurücknehmen:
bash bbrv3/apply-patches.sh --check --reverse /pfad/zu/crdroid
bash bbrv3/apply-patches.sh --reverse /pfad/zu/crdroid
```

Der Installer simuliert die Anwendung und lehnt Änderungen an einem unsauberen
Zielrepository standardmäßig ab. Danach sind Kernel-/ROM-Build und Installation
nötig. Die Serie vor Erzeugung der Kernel-`.config` anwenden. Der Zusatzpatch
setzt `CONFIG_TCP_CONG_BBR3=y`, `CONFIG_DEFAULT_BBR3=y` und
`CONFIG_DEFAULT_TCP_CONG="bbr3"`. Er verändert kein laufendes Gerät.

Das echte Kernel-Kconfig-Werkzeug hat `gki_defconfig` mit
`vendor/sun_perf.config` und `vendor/oplus/sun_perf.config` aufgelöst:
zuvor `cubic`, danach `bbr3`, BBRv3 fest eingebaut. Nach Installation eines
neuen Builds `/proc/sys/net/ipv4/tcp_congestion_control` prüfen;
Laufzeittuning kann den Kernelstandard überschreiben. Geräteabnahme bleibt offen.

## Algorithmusstand, geprüft am 03.10.2026

Alle 38 verglichenen Konstanten entsprechen Googles TCP-Branch `v3`, Revision
`90210de4b779d40496dee0b89081780eeddf2a60` vom 18.03.2025.
Der neuere Branch `bbr-v3-2026-09-16-01` bei
`674859761ded9f32690c7bdaf22ef585531452ed` enthält weitere Änderungen:

| Bereich | Diese Fassung | Neuer Google-TCP-Stand |
|---|---|---|
| DRAIN-Gain | `88/256`, etwa 0,344 | `128/256`, 0,5 |
| DRAIN-Rundengrenze | fehlt | Ausstieg nach mehr als 3 Runden |
| Verlust-Undo | bisherige Modellgrenzen-Rücknahme | Zustand vor erstem verlorenen skb sichern; STARTUP/PROBE_UP wiederherstellen |
| PROBE_UP-Cwnd | 2,25 BDP bereits enthalten | 2,25 BDP |

ECN/PLB, privater CC-Speicher und Callback-/BPF-Schnittstellen unterscheiden
sich ebenfalls. Die Übernahme braucht einen gezielten Android-6.6-Backport.
**Diese neueren Änderungen sind nicht enthalten.** Ein aktueller WildKernels-
Quellpatch bedeutet nicht den neuesten Google-Algorithmus. QUICHE ist eine eigene
QUIC-Implementierung; dieses Modul betrifft ausschließlich TCP.
Die gepinnten Vergleichsquellen stehen in der [englischen Anleitung](README.md).

## Verpackung und Prüfstatus

[NOTICE](NOTICE) nennt Quellen, Autoren, Revisionen und SHA256-Werte.
Die Repo-Fassung ergänzt den Zielkopf und entfernt Leerzeichen am Ende von fünf
hinzugefügten Zeilen. Die produktive Vorlage bleibt bytegleich erhalten.
Die Fassungen haben deshalb unterschiedliche Prüfsummen, ohne Algorithmusänderung.

Die Quell- und Helferprüfungen sind vollständig verifiziert:

- 34 von 34 Tests im Helfer-Test (`test-apply-script.sh bbrv3`) erfolgreich.
- Strikte Vorwärts- und Rückwärtsanwendung (2/2 Patches) auf Referenz-Commit `b69d2cc667dd` und aktuellem Branch `16.0` (`check-reference.sh`).
- Fehlerfreie Core-Patch-Dry-Run-Simulation gegen den lokalen OnePlus-`sm8750`-Kernelbaum.
- Gemeinsame Anwendung des BBRv3-Core mit der korrigierten SUSFS-Upstream-Patchdatei im isolierten Kernelindex verifiziert.

**Kernel-Build und Geräteabnahme:** Auf dem Referenzgerät **OnePlus 13 (`dodge`, CPH2653)**
ist im aktuellen Kernel Linux 6.6 derzeit BBRv1 aktiv (`net.ipv4.tcp_congestion_control = bbr`).
BBRv3 registriert sich als `bbr3`; dessen Bereitstellung erfordert das Einspielen des Patches
und die entsprechende Kernel-Option (`CONFIG_TCP_CONG_BBR3=y`) im nächsten Kernel-Build.
Quellprüfungen belegen keine Durchsatz- oder Latenzgewinne. Modulprüfungen laufen bei jedem
Push über GitHub Actions.


## Lizenz

Kernelmaterial behält seine Dateihinweise und die Regeln aus
[COPYING](COPYING.kernel), [GPL-Text](LICENSE) und
[Syscall-Ausnahme](LICENSE-Linux-syscall-note). Die `Dual BSD/GPL`-Kennzeichnung
des BBR-Core und seine Autoren bleiben erhalten; keine BSD-Variante wird erfunden.
Eigene Doku, Metadaten und Installer: [Apache 2.0](LICENSE-APACHE-2.0).

Mail-Vorspann-Aufzählung und -Trennlinie sind für die strikte Patchprüfung kommentiert.
