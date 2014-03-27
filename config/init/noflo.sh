#!/bin/bash

NODE=/opt/node/bin/node
NOFLO_PROJECT_ROOT=/home/pi/Projects/ingress-table
SERVER_JS_FILE=$NOFLO_PROJECT_ROOT/node_modules/.bin/noflo
NOFLO_GRAPH=$NOFLO_PROJECT_ROOT/graphs/bgt9b.json
USER=pi
OUT=/home/pi/nodejs.log

case "$1" in

start)
	echo "starting node: $NODE $SERVER_JS_FILE"
        cd $NOFLO_PROJECT_ROOT
	sudo -u $USER NOFLO_PROJECT_ROOT=$NOFLO_PROJECT_ROOT $NODE $SERVER_JS_FILE $NOFLO_GRAPH > $OUT 2>$OUT &
	;;

stop)
	killall $NODE
	;;

*)
	echo "usage: $0 (start|stop)"
esac

exit 0
