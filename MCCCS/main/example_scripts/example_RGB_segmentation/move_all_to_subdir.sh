#!/bin/bash
#
# Modified 2018-04-14 by C. Klukas
#
if [ "$#" -ne 1 ]; then
	echo "Illegal number of parameters (only one is supported, the postfix of the filenames)"
	exit 1
fi
export R=$1
find *$1 -maxdepth 0 -type f -print0 | xargs -I '{}' -0 bash -c 'F={} && mkdir -p ${F%$R}'
find *$1 -maxdepth 0 -type f -print0 | xargs -I '{}' -0 bash -c 'F={} && mv $F $(basename -s $R $F)'
