#!/bin/bash
NPROCS=1
OS=$(uname -s)

if [ "$OS" == "Linux" ];
then
  NPROCS=$(grep -c ^processor /proc/cpuinfo)
fi
if [ "$OS" == "Darwin" ]; 
then
  NPROCS=$(sysctl -n hw.ncpu)
fi
if [[ "$(uname)" == CYGWIN* ]]
then
	NPROCS=$(wmic cpu get NumberOfLogicalProcessors | sed -n -e '2{p;q}' | sed ':a;N;$!ba;y/\n/ /' | sed 's/ //g')
fi

if [ "$4" == "s" ];
then
	NPROCS=1
	echo "Operation mode: single-threaded"
else
if [ "$4" == "h" ];
then
	NPROCS=$(($NPROCS/2))
	echo "Operation mode: utilize half of the CPU cores ($NPROCS)"
else
	echo "Operation mode: utilize all CPU cores ($NPROCS detected)"
fi
fi

#if parallel is not installed use xargs instead:
par="parallel --halt 2 -u --gnu -j $NPROCS"
type parallel >/dev/null 2>&1 || par="xargs -n1 -P$NPROCS -I{}" 
echo "Parallel command: $par"
