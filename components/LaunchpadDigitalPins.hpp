// Based on https://github.com/energia/Energia/blob/master/hardware/lm4f/variants/stellarpad/pins_energia.h

/* microflo_component yaml
name: LaunchpadDigitalPins
description: Pin numbers for the digital I/O pins on the Launchpad TM4C123 from Texas Instruments (TI)
inports:
  in:
    type: bang
    description: ""
outports:
  pb5:
    type: number
    description: ""
  pb0:
    type: number
    description: ""
  pb1:
    type: number
    description: ""
  pe4:
    type: all
    description: ""
  pe5:
    type: all
    description: ""
  pb4:
    type: all
    description: ""
  pa5:
    type: all
    description: ""
  pa6:
    type: all
    description: ""
  pa7:
    type: all
    description: ""
  pa2:
    type: all
    description: ""
  pa3:
    type: all
    description: ""
  pa4:
    type: all
    description: ""
  pb6:
    type: all
    description: ""
  pb7:
    type: all
    description: ""
  _unused16:
    type: all
    description: ""
  pf0:
    type: all
    description: ""
  pe0:
    type: all
    description: ""
  pb2:
    type: all
    description: ""
  _unused20:
    type: all
    description: ""
  _unused21:
    type: all
    description: ""
  _unused22:
    type: all
    description: ""
  pd0:
    type: all
    description: ""
  pd1:
    type: all
    description: ""
  pd2:
    type: all
    description: ""
  pd3:
    type: all
    description: ""
  pe1:
    type: all
    description: ""
  pe2:
    type: all
    description: ""
  pe3:
    type: all
    description: ""
  pf1:
    type: all
    description: ""
  pf4:
    type: all
    description: ""
  pd7:
    type: all
    description: ""
  pd6:
    type: all
    description: ""
  pc7:
    type: all
    description: ""
  pc6:
    type: all
    description: ""
  pc5:
    type: all
    description: ""
  pc4:
    type: all
    description: ""
  pb3:
    type: all
    description: ""
  pf3:
    type: all
    description: ""
  pf2:
    type: all
    description: ""

microflo_component */

class LaunchpadDigitalPins : public Component {
public:
    LaunchpadDigitalPins() : Component(outPorts, LaunchpadDigitalPinsPorts::OutPorts::pf2+1) {}
    virtual void process(Packet in, MicroFlo::PortId port) {
        using namespace LaunchpadDigitalPinsPorts;
        if (port == InPorts::in) {
            for (int outPort=0; outPort < OutPorts::pf2+1; outPort++) {
                const long pinNumber = outPort+2;
                send(Packet(pinNumber), outPort);
            }
        }
    }
private:
    Connection outPorts[LaunchpadDigitalPinsPorts::OutPorts::pf2+1];
};
