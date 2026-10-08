# Gaming-Lade-Bypass

Pausiert das Laden, solange ein Spiel läuft, damit der Akku in langen Sitzungen
nicht gleichzeitig geladen und entladen wird. Beim Verlassen des Spiels wird der
vorherige Ladezustand genau so wiederhergestellt, wie er war.

Die Schwelle ist im GameSpace-Panel sichtbar einstellbar:
**Akkustand bei Spielstart** oder ein fester Wert zwischen 70 und 100 %.

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

Geprüft auf einem OnePlus 13 (dodge), crDroid 16.0:

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

crDroid 16.0 (Android 16). Andere ROMs sind ungetestet. Die genauen
Upstream-Stände, gegen die die Diffs erzeugt wurden, stehen in `NOTICE`.
