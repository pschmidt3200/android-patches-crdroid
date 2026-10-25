# Gaming-Lade-Bypass

Pausiert das Laden, solange ein Spiel läuft, damit der Akku in langen Sitzungen
nicht gleichzeitig geladen und entladen wird. Beim Verlassen des Spiels wird der
vorherige Ladezustand genau so wiederhergestellt, wie er war.

Die Schwelle ist im GameSpace-Panel sichtbar einstellbar:
**Akkustand bei Spielstart** oder ein fester Wert zwischen 70 und 100 %.

> **crDroid-17.0-Fassung: am Gerät geprüft.** Diese Patches zielen auf crDroid 17.0 und lassen
> sich an den [`NOTICE`](NOTICE)-Referenzcommits sauber anwenden und zurücknehmen. Am 20.10.2026
> hat der Maintainer das Modul auf einem OnePlus 13 mit einem crDroid-17.0-Build dieser Reihe
> abgenommen, mit Spiel im Vordergrund und angeschlossenem Netzteil: Mit *Akkustand bei
> Spielstart* (66 %, angehoben auf 70 %) stoppte das Laden bei 70 % und der Strom fiel auf 0 A;
> mit fester Grenze 90 % lud das Telefon über die 80-%-Grenze der bestehenden Ladesteuerung
> hinaus und stoppte bei 90 %. Hintergrund und Rückkehr ins Spiel hielten die Pause. In beiden
> Läufen wurden beim Spielende die vorherigen Ladeeinstellungen zurückgeschrieben, danach lud
> das Telefon wieder. Das Modul ist außerdem Teil des 17.0-ROM-Builds des Maintainers vom
> 22.10.2026, gebaut aus diesem Repository auf Stand `4bdecab`. Weitere unten beschriebene
> Ergebnisse stammen aus crDroid 16.0. Die 16.0-Fassung bleibt auf dem Branch
> [`16.0`](https://github.com/pschmidt3200/android-patches-crdroid/tree/16.0/gaming-charge-bypass).

## Was die zwei Patches tun

| Patch | Repository | Wirkung |
|---|---|---|
| `crdroid_framework_gaming_bypass.patch` | `frameworks/base` | `GameStateDispatcher` setzt die Ladepause bei Spielstart und stellt den gesicherten Zustand bei Spielende zurück |
| `crdroid_gamespace_charging_limit.patch` | `packages/apps/GameSpace` | die Schwellen-Option im In-Game-Panel |

Sie gehören zusammen. Wer nur einen anwendet, hat entweder eine Option ohne
Wirkung oder eine Wirkung ohne Option.

## Wie es arbeitet

Die Ladepause nutzt die LineageOS-Ladesteuerung, die der Baum schon enthält —
denselben Setter, den man über *Einstellungen → Akku → Ladesteuerung* erreicht.
Vor jeder Änderung werden Modus, Limit und Aktiv-Flag gesichert; bei Spielende
werden sie zurückgeschrieben und die Sicherung gelöscht. Es wird kein Kernel-Knoten
direkt beschrieben, kein Ladetreiber angefasst und keine Vendor-Schnittstelle
ergänzt.

Scheitert ein Schreibvorgang, bleibt die Sicherung erhalten und es bleibt nichts
halb gesetzt zurück.

## Warum die Schwelle bei 70 beginnt

Der LineageOS-Provider prüft `charging_control_charging_limit` und lehnt Werte
unter 70 ab. Niedrigere Werte können deshalb nicht funktionieren, unabhängig von
Gerät und Akkustand, und die Option bietet sie nicht an. Aus demselben Grund hebt
die Einstellung „Akkustand bei Spielstart" einen Startwert unter 70 auf 70 an —
sonst würde der Standardfall für jeden scheitern, der ein Spiel mit weniger als
70 % Akku startet.

## Am Gerät geprüft — und was nicht

Geprüft auf einem OnePlus 13, crDroid 16.0:

* Schwelle 70 % greift und wirkt, acht Zyklen über vier Spiele
* Ladestopp an der Schwelle: Status 2 (lädt) → 4 (lädt nicht),
  Strom −2976 mA → 0 mA bei genau Level 70
* Rückstellung bei Spielende, acht Zyklen, immer auf den gesicherten Originalzustand
* Rückstellung nach einem Neustart mitten im Spiel, 82 s nach dem Booten
* stabil auch bei 0,5 s Abstand zwischen den Zyklen
* ohne laufendes Spiel wird das Laden nie angetastet

**Nicht am Gerät geprüft:** die Schwellen 80, 90 und 100 %. Dass der Provider
diese Werte annimmt, wurde gesondert gemessen — das ist nicht dasselbe wie ein
Gerätetest.

## Voraussetzungen

crDroid 17.0 (Android 17); für 16.0 den Branch `16.0` dieses Repositorys nehmen. Andere ROMs
sind ungetestet. Die genauen
Upstream-Stände, gegen die die Diffs erzeugt wurden, stehen in `NOTICE`.
