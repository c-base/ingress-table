Ingress Table
=============

The software side of a "physical Intel map", built with [NoFlo](http://noflojs.org) and [MicroFlo](http://microflo.org).

## How does this work?

We have a NoFlo graph that periodically pulls portal status information from a cloud-based data provider, and converts that to status information to be shown on the table surface.

The status information is then transmitted to a microcontroller that shows portal owners, attack notifications, etc. using the LEDs.

## Starting and Stopping the Service

This is the configuration file for supervisord (needs to be installed through apt-get install supervisor):. Filename: /etc/supervisor/conf.d/ingress-table.conf

    [program:ingress_table]
    command=node ./node_modules/.bin/noflo graphs/bgt9b.json
    directory=/home/ubuntu/ingress-table
    stdout_logfile=/home/ubuntu/ingress_table_output.txt
    redirect_stderr=true
    autostart=true
    user=ubuntu
    stopwaitsecs=2

The stopwaitsecs=2 is there because we need to do a kill -9 after the service is stopped.

You can start/stop/look at status the service using these commands:

    supervisorctl start ingress_table
    supervisorctl stop ingress_table
    supervisorctl status



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
to control them. We use three IRF-820 MOSFETs per RGB strip.
  
![](https://raw.githubusercontent.com/c-base/ingress-table/master/RGB-Channel%20Schematic.png)

This is the circuit for one channel only, you must build this 5 times. Here is an example of how you could
put in on a perfboard:

![](https://github.com/c-base/ingress-table/blob/8ff081f4ea03c158d300b17b2abb8601b72aa9ce/RGB-Channel%20Breadboard-Example.png)


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
