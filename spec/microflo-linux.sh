#!/bin/bash -e
NAME=$1
PORT=$2

FIRMWARE_FILE=build/linux/$NAME/$NAME
SERIAL_FILE=test.$NAME.microflo
COMPONENT_MAP=build/linux/$NAME/$NAME.component.map.json
OPTIONS="--port $PORT --baudrate 115200 --serial $SERIAL_FILE --graph graphs/$NAME.fbp"

# Make sure we clean up
trap 'kill $(jobs -p)' EXIT

$FIRMWARE_FILE $SERIAL_FILE &
sleep 2
./node_modules/.bin/microflo runtime $OPTIONS --componentmap $COMPONENT_MAP
