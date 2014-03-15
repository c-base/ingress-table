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
