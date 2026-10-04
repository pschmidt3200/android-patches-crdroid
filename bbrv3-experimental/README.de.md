# BBRv3 Experiment 2026 für crDroid sm8750

> **EXPERIMENTELL — nur verwenden, wenn du etwas testen willst.**
> Für normale Builds gehört das Modul [bbrv3](../bbrv3/) in den Kernel. Dieses Modul
> ersetzt es für einen Testbuild, es ist **nie eine Ergänzung**: Wende nie beide
> Module auf denselben Kernel-Baum an. Ein Vorteil gegenüber `bbrv3` ist bisher
> nicht gemessen (siehe *Messungen*), und Googles neuer Code ist noch keine fertige Veröffentlichung.

Das Modul enthält eine vollständige Serie für **crDroid 16.0** und dessen OnePlus-
`sm8750`-Kernel (Android 15 / Linux 6.6):

1. `patches/bbrv3-android15-6.6.patch` — der BBRv3-Kern, bytegleich mit `bbrv3` v1.2.
2. `patches/bbrv3-default-android15-6.6.patch` — baut BBRv3 fest ein und wählt `bbr3`
   als TCP-Standard, bytegleich mit dem Zusatzpatch aus `bbrv3`.
3. `patches/bbrv3-2026-experimental-android15-6.6.patch` — **das Experiment**: Googles
   TCP-BBR-Zweig `bbr-v3-2026-09-16-01` (Stand `674859761ded`), auf Linux 6.6 zurückportiert.

## Was das Experiment ändert

| Bereich | `bbrv3`-Kern | Dieses Experiment (Google 2026) |
|---|---|---|
| DRAIN-Pacing-Gain | `88/256` (~0,344) | `128/256` (0,5) |
| DRAIN-Rundengrenze | keine | Ausstieg nach mehr als 3 Runden |
| Rücknahme bei fälschlichem Verlust | ältere modellgebundene Rücknahme | Zustand vor dem ersten verlorenen skb sichern, STARTUP/PROBE_UP wiederherstellen |
| BBR-ECN, `ecn_low`, PLB | vorhanden | entfernt, wie in Googles Update |

Linux 6.6 kann Googles Datei nicht unverändert übernehmen. Die Anpassung behält den
Heap-Zustand und die Callback-Schnittstelle des Kerns; Googles BPF-kfunc-Schnittstelle
ist **nicht** portiert. Den TSO-Hook des Kerns behält das Experiment absichtlich, damit
ein Vergleich mit `bbrv3` nur die Algorithmusänderung misst. Details und Quellen in [NOTICE](NOTICE).

## Voraussetzungen und Anwendung

* Ziel: `kernel/oneplus/sm8750`, Zweig `16.0`, Referenz-Commit
  `b69d2cc667dd0a57adb78b54c9a3453f5c5a5b35`, auf einem Baum **ohne** das Modul `bbrv3`.
* Referenzgeräte: OnePlus 13 / Pad 3 mit diesem gemeinsamen Kernel.
* Bash und Git; alle Moduldateien aus demselben Patch-Commit/-Tag verwenden.

```bash
bash bbrv3-experimental/apply-patches.sh --check /path/to/crdroid
bash bbrv3-experimental/apply-patches.sh /path/to/crdroid
# Zurück zu einem normalen Build: entfernen und danach das Modul bbrv3 verwenden:
bash bbrv3-experimental/apply-patches.sh --check --reverse /path/to/crdroid
bash bbrv3-experimental/apply-patches.sh --reverse /path/to/crdroid
```

Der Installer prüft die ganze Serie zuerst in einer Sandbox und verändert standardmäßig
kein verschmutztes Zielrepository. Vor dem Erzeugen der Kernel-`.config` anwenden.

**Am Gerät prüfen**, ob wirklich der Experiment-Kernel läuft:

```bash
adb shell cat /sys/module/tcp_bbr3/version
```

`3-2026x` heißt: Das Experiment ist aktiv; der normale `bbrv3`-Kernel meldet `3`.
`/proc/sys/net/ipv4/tcp_congestion_control` zeigt in beiden Fällen `bbr3`.

## Messungen

Uploads von einem OnePlus 13 (`dodge`) über Wi-Fi 7 zu einem kabelgebundenen Rechner,
`iperf3`, 20 s, ein Datenstrom, je Kernel fünf Runden, durch einen identischen
kontrollierten Engpass (100 Mbit/s, +20 ms, 0,3 % zufälliger Verlust), damit
WLAN-Schwankungen das Ergebnis nicht bestimmen. Mediane, exakter zweiseitiger Mann-Whitney-Test:

| `bbr3` | `bbrv3`-Kern | Experiment | p |
|---|---|---|---|
| Durchsatz | 47,3 Mbit/s | 45,2 Mbit/s | 1,00 |
| Retransmits | 304 | 268 | 0,04 * |
| TCP-RTT | 36 ms | 43 ms | 0,69 |
| Ping unter Last | 62 ms | 69 ms | 0,42 |

\* Die Kontrollverfahren (`bbr`, `cubic`) zeigten im selben Zeitraum einen ähnlichen
Rückgang der Retransmits; er wird deshalb nicht dem Experiment zugeschrieben. Ergebnis:
**kein messbarer Unterschied und keine Verschlechterung** in diesem Szenario. Zufälliger
Verlust löst die Rücknahme bei fälschlichem Verlust nicht aus, und 20-s-Läufe gewichten
die DRAIN-Änderung kaum; gezielte Tests (vertauschte Pakete, kurze Verbindungen) fehlen.

**Geräteabnahme:** OnePlus 13 (`dodge`, CPH2653), Kernel-Build
`Sun Oct 4 11:15:40 CEST 2026`: `version` = `3-2026x`, `bbr3` als Standard, 64
bestehende TCP-Verbindungen auf `bbr3` (`ss -tin`), keine BBR-/TCP-Warnungen im Kernel-Log. Kernel
und Module wurden vollständig aus dem gepatchten Baum gebaut.

## Paketierung und Prüfung

Patch 1 und 2 sind Kopien der Dateien aus `bbrv3` (SHA256 in [NOTICE](NOTICE)).
Patch 3 wurde vor dem Paketieren am Referenz-Commit geprüft: striktes Anwenden,
Zurücknehmen und erneutes Anwenden mit Fuzz 0 auf dem Kern v1.1 und v1.2, jeweils mit
und ohne Zusatzpatch; ARM64-Kompilierung von `tcp_bbr3.o` und den berührten TCP-Objekten
mit Android-Clang `r563880c`, ohne Warnungen. Die paketierte Datei unterscheidet sich
von der geprüften nur im Kommentarkopf und in einem Code-Kommentar.

## Lizenz

Kernel-Material folgt den Hinweisen der Upstream-Dateien und dem Kernel-
[COPYING](COPYING.kernel), dem [GPL-Text](LICENSE) und der
[Syscall-Ausnahme](LICENSE-Linux-syscall-note). Googles Algorithmusdatei steht unter
`GPL-2.0 OR BSD-3-Clause`; BBR behält seine `Dual BSD/GPL`-Erklärung und die Autoren.
Eigene Doku, Metadaten und Installer stehen unter [Apache 2.0](LICENSE-APACHE-2.0).

[English instructions](README.md)
