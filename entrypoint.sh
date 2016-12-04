#!/bin/bash

DUPLICATI_CMD='mono /app/Duplicati.CommandLine.exe'
DUPLICATI_DATADIR=/root/.config/Duplicati

if [ ! "$(ls -l ${DUPLICATI_DATADIR}/*.sqlite 2>/dev/null |wc -l)" -gt "0" ]; then
	echo 'Init process in progress...'

	for f in /docker-entrypoint-init.d/*; do
		case "$f" in
			*.sh)     echo "$0: running $f"; . "$f" ;;
			*)        echo "$0: ignoring $f" ;;
		esac
		echo
	done
fi

if [ -z "$1" ]; then
    if [ ! -n "$DUPLICATI_PASS" ]; then
      echo "ERROR- DUPLICATI_PASS must be defined"
      exit 1
    fi
	exec mono /app/Duplicati.Server.exe --webservice-port=8200 --webservice-interface=* --webservice-password=${DUPLICATI_PASS}
else
	$DUPLICATI_CMD $@
	if [ "$?" -eq 100 ] && [ -n "$ENABLE_AUTO_REPAIR" ]; then
		echo "Trying to repair local storage."
		$DUPLICATI_CMD $(echo $@ | sed "s/^\w*\s/repair /g" | sed -r 's/[* ]\/[a-zA-Z_].*+//')
		$DUPLICATI_CMD $@
	fi
fi