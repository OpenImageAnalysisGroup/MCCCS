APPPATH=$(realpath $1)
#export MBP="$APPPATH/lib/iap.jar:$APPPATH/mcccs.jar"
LIBPATH=$(realpath $1/..)
export JARLIST=$(find $LIBPATH/lib | grep jar$ | paste -sd ":" -)
export MBP="$JARLIST:$LIBPATH/mcccs.jar"
# avoid parallel warning message, by setting shell variable
export SHELL=/bin/bash

if [[ "$(uname)" == CYGWIN* ]]
then
	MBP=$(cygpath -mp $MBP)
fi

cd "$2"
rm -f all_results.csv
rm -f all_fgbg.arff
rm -f all_disease.arff
rm -f fgbgClassifier.data
rm -f diseaseClassifier.data
rm -f fgbg.model
#echo "mcccs jar:" $MBP
if [ "$(uname)" == "Darwin" ]; then
	export JAVA="java -Dapple.awt.UIElement=true -cp $MBP workflow"
else
	export JAVA="java -cp $MBP workflow"
fi 

export WEKA="java -cp $JARLIST"

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
echo "Requested operation mode: $3"
if [ "$3" == "s" ];
then
	NPROCS=1
	echo "Operation mode: single-threaded"
else
if [ "$3" == "h" ];
then
	NPROCS=$(($NPROCS/2))
	echo "Operation mode: utilize half of the CPU cores ($NPROCS)"
else
	echo "Operation mode: utilize all CPU cores ($NPROCS detected)"
fi
fi

export SYSTEM_cpu_n=$NPROCS

#if parallel is not installed use xargs instead:
par="parallel --halt 2 -u --gnu -j $NPROCS"
type parallel >/dev/null 2>&1 || par="xargs -n1 -P$NPROCS -I{}" 
echo "Parallel command: $par"
