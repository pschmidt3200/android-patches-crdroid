# Oplus Hardware Fixes

Zwei Korrekturen für `hardware/oplus` auf **crDroid 16.0 (Android 16)**: Die
LTPO-Einstellung zeigt jetzt die tatsächliche Panel-Konfiguration statt der letzten
gespeicherten Auswahl, und die Touch-HAL prüft Treiber- und Binder-Antworten, anstatt
Erfolg anzunehmen.

Keiner der beiden Patches schaltet eine Funktion ein, ändert eine Abtastrate oder fasst
einen Kernel-Knoten an. Sie bringen vorhandenen Code dazu, die Wahrheit zu sagen, wenn die
Hardware nein sagt.

---

## Was sie korrigieren

### LTPO: die aktuelle Konfiguration zeigen, nicht den letzten Wunsch

`crdroid_oplus_ltpo_readback.patch`

Die Einstellungsseite speicherte die Auswahl und zeigte sie zurück — auch wenn das Panel
sie nie angenommen hatte. Nach einem fehlgeschlagenen Schreibvorgang behauptete der
Schalter einen Zustand, in dem die Hardware nicht war.

Jetzt liest die Seite beim Öffnen und bei Resume die `adfr_config`-Maske des Panels. Eine
Auswahl wird erst gespeichert, wenn Schreiben, Flush, Close und ein **exakter Rücklesevorgang**
der Maske alle erfolgreich waren. Ist die Maske nicht lesbar, wird die Umschaltung
deaktiviert statt einen gespeicherten Wunsch darzustellen; schlägt ein Schreibvorgang fehl,
zeigt die Seite den tatsächlichen Wert, soweit er lesbar ist. Die automatische
Preference-Persistenz ist unterbunden, es wird also nichts hinter dem Rücken gespeichert.

### Touch-HAL: bei Fehlern anhalten statt Erfolg melden

`crdroid_oplus_touch_error_handling.patch`

Drei Pfade nahmen an, ihre Schreibvorgänge hätten funktioniert:

* **GloveMode** prüft jetzt den Binder-Status, negative Treiberantworten und das Leseformat.
  Leere oder ungültige Antworten sind ein Fehler statt eines unterstellten „aus". Das
  vorhandene Format `Status:Zähler` bleibt gültig (etwa `1:2`, `0:10`, `1:100`); nur das
  erste Feld bestimmt den gemeldeten Zustand.
* **TouchscreenGesture** akzeptiert nur konfigurierte Keycodes, begrenzt vor Subtraktion und
  Shift, und liest die vollständige hexadezimale Maskenantwort ohne Exception. Die
  resultierende Dezimalmaske muss vor jedem Schreibvorgang in acht Bytes passen — längere
  Werte ignoriert der Treiber stillschweigend und quittiert dennoch Erfolg.
* **Beide Touch-Schreibschritte** prüfen Binder-Status und negatives Treiberergebnis. Nach
  dem ersten Fehler folgt kein zweiter Schreibzugriff, ein halb angewendeter Zustand kann
  also nicht entstehen. Der Power-Double-Tap-Pfad prüft zusätzlich den Vendor-Proxy.

Gesten-Knoten, Gestenliste und Touch-Abtastraten bleiben unverändert.

---

## Voraussetzungen

* crDroid-16.0-Quellbaum mit `hardware/oplus`
* Ein Oplus-/OnePlus-Gerät, dessen Baum dieses Repository verwendet

Beide Patches betreffen ausschließlich `hardware/oplus`. Der exakte Upstream-Commit, gegen
den die Serie vorbereitet wurde, steht in `NOTICE`.

## Installation

```bash
# 1. Zuerst Kompatibilität prüfen (simuliert die ganze Serie, ändert nichts):
./apply-patches.sh --check /pfad/zu/crdroid

# 2. Einspielen:
./apply-patches.sh /pfad/zu/crdroid

# 3. Bei Bedarf zurücknehmen:
./apply-patches.sh --reverse /pfad/zu/crdroid
```

## Prüfung

Beide Patches wurden auf ein unverändertes `hardware/oplus` beim in `NOTICE` genannten
Commit angewendet und wieder zurückgenommen; vorwärts und rückwärts sauber.

Auf dem Referenzgerät (OnePlus 13, crDroid-16.0-Build vom 07.10.2026):

* **LTPO** — Ausschalten schrieb `adfr_config` von `0x109f` auf `0x0`; nach erneutem Öffnen
  der Seite stand der Schalter **aus**, also der echte Zustand und nicht die gespeicherte
  Auswahl. Zurückschalten stellte exakt `0x109f` wieder her, keinen Teilwert. Das Display
  lief weiter mit variabler Bildwiederholrate (120/90/60 fps), das Protokoll blieb sauber.
* **Touch** — Double-Tap-to-Wake wurde unter *Einstellungen → Display* ein- und ausgeschaltet,
  beide Richtungen funktionierten. Der gepatchte Pfad protokollierte die vollständige Kette:
  Lesen des Gestentyps, Schreiben von `gesture_enabled`, Schreiben von `gesture_type` und die
  Erfolgsquittung des Treibers. Alle drei Touch-HAL-Schnittstellen blieben ohne Fehler
  registriert.

Der Handschuhmodus wurde auf dem Referenzgerät nicht ausgeübt (dort nicht genutzt); seine
Korrektur stützt sich daher auf die isolierte Testreihe, nicht auf eine Geräteprüfung.

## Umfang und Grenzen

* Keine proprietären Binärdateien, Firmware oder Treiberquellen enthalten oder geändert.
* Keine Funktion wird eingeschaltet, die nicht bereits eingeschaltet war; keine Touch-Rate
  erhöht.
* Die Fehlerpfade, die diese Patches absichern, treten im Normalbetrieb nicht auf. Ihr Wert
  zeigt sich, wenn ein Treiber- oder Binder-Aufruf fehlschlägt — dann stürzt nichts ab,
  nichts bleibt halb geschrieben, und die Oberfläche behauptet keinen Zustand mehr, in dem
  die Hardware nicht ist.
* Auf einer Gerätefamilie geprüft. Rückmeldungen von anderen Oplus-Geräten sind als
  Information willkommen.

## Lizenz

Apache License, Version 2.0 — siehe `LICENSE` und `NOTICE`.
