Ingress Table
=============

The software side of a "physical Intel map", built with [NoFlo](http://noflojs.org) and [MicroFlo](http://microflo.org).

## How does this work?

We have a NoFlo graph that periodically pulls portal status information from a cloud-based data provider, and converts that to status information to be shown on the table surface.

The status information is then transmitted to a microcontroller that shows portal owners, attack notifications, etc. using the LEDs.

## Hardware

* Beaglebone Black running NoFlo
* Launchpad Tiva running MicroFlo
* Individually controllable LEDs for portals
* LED strips for street and floor lighting
* USB chargers for agents running out of battery

## LED strip i/o pins

```
J2
---

PF0 Red1
PB7 Green1
PD1 Blue1

PA2 -> SSI0Clk => Portallights Clock (CKI)

J4
---

PF3 Red2
PC4 Green2
PC5 Blue2

PF2 Red Bottom

J3
---

PD0 Red3
PD1 Green3
PF1 Blue3

J1
---
PB5 Red4
PE4 Green4
PE5 Blue4

PA6 Green Bottom
PA7 Blue Bottom

PA5 -> SSI0Tx => Portallights Data (SDI)
```
