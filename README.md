Ingress Table [![Build Status](https://travis-ci.org/c-base/ingress-table.svg?branch=master)](https://travis-ci.org/c-base/ingress-table) [![Dependency Status](https://www.versioneye.com/user/projects/542712fd75d3720e03000053/badge.svg?style=flat)](https://www.versioneye.com/user/projects/542712fd75d3720e03000053) [![Greenkeeper badge](https://badges.greenkeeper.io/c-base/ingress-table.svg)](https://greenkeeper.io/)
=============

The software side of a "physical Intel map", built with [NoFlo](http://noflojs.org) and [MicroFlo](http://microflo.org). Please read the [introductory blog post](http://bergie.iki.fi/blog/ingress-table/) for more information. The actual table can be seen live at the [c-base](http://c-base.org/) space station in Berlin.

## How does this work?

We have a NoFlo graph that periodically pulls portal status information from a cloud-based data provider, and converts that to status information to be shown on the table surface.

The status information is then transmitted to a microcontroller that shows portal owners, attack notifications, etc. using the LEDs.

## Starting and Stopping the Service

Copy `noflo.init` to `/etc/init.d/noflo.sh` and create the links at `/etc/rc2.d/S90noflo.sh` and `/etc/rc2.d/K10noflo.sh`
pointing to the init script.

The init script needs timeout to work: https://github.com/pshved/timeout. Copy timeout to /home/pi/timeout and make it executable.

Now you can start/stop the service using /etc/init.d/noflo.sh {start|stop}


## Hardware

* Beaglebone Black running NoFlo
* Arduino Leonardo running Microflo for controlling the WS2801-based LED strand (portal lights)
* 50 individually controllable LEDs for portals (based on the WS2801 controller chip)
* 5 LED strips for streets (map background) and floor lighting
* Launchpad Tiva running MicroFlo for controlling the 5 RGB-LED strips
* USB chargers for agents running out of battery

### LED driver circuit

The RGB-LED strips we use run on 12 Volts DC and have one shared plus pole and an individual
minus pole for each color. They cannot be driven by the Tiva itself so we use an N-Channel MOSFET
to control them. We use three [IRL540N MOSFETs](http://www.irf.com/product-info/datasheets/data/irl540n.pdf) (named Q1, Q2, Q3) per RGB strip.
  
![](https://raw.githubusercontent.com/c-base/ingress-table/master/RGB-Channel%20Schematic.png)

This is the circuit for one channel only, you must build this 5 times. Here is an example of how you could
put in on a perfboard:

![](https://github.com/c-base/ingress-table/blob/8ff081f4ea03c158d300b17b2abb8601b72aa9ce/RGB-Channel%20Breadboard-Example.png?raw=true)


### LED strip i/o pins


```
J2
---

PB7 Green1
PB6 Blue1

PA2 -> SSI0Clk => Portallights Clock (CKI), not used at the moment

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
PB4 Red1
PB5 Red4
PE4 Green4
PE5 Blue4

PA6 Green Bottom
PA7 Blue Bottom

PA5 -> SSI0Tx => Portallights Data (SDI), not used at the moment
```

**Note**: out-of-the box on the Tiva the pins PB6, PB7, PD0, PD1 can't be used. You [can disconnect the R9 and R10 resistors](http://e2e.ti.com/support/microcontrollers/tiva_arm/f/908/t/290329.aspx) to make them usable.

## Flashing and resetting the Arduino

Resetting the MCU:

    stty -F /dev/ttyACM1 1200

    make upload SERIALPORT=/dev/ttyACM1 BAUDRATE=57600 MODEL=leonardo GRAPH=../ingress-table/graphs/PortalLights.fbp
