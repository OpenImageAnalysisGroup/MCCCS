set -e # stop script in case of error

PREDICT_FOLDER="$(pwd)/predict_folder.sh"
CREATE_CHANNEL_FILES="$(pwd)/create_channel_files.sh"
export SPLIT_ARFF="$(pwd)/split_arff.sh"

if [ "$(uname)" == "Darwin" ]
then
	realpath() {
		[[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
	}
fi

APPPATH=$(realpath $1)
LIBPATH=$(realpath $1/..)

export JARLIST=$(find "$LIBPATH/lib" | grep jar$ | paste -sd ":" -)
export MBP="$JARLIST:$LIBPATH/mcccs.jar"
echo MBP=$MBP
if [[ "$(uname)" == CYGWIN* ]]
then
	MBP=$(cygpath -mp $MBP)
fi

chmod +x *.sh

if [ "$(uname)" == "Darwin" ]
then
	export JAVA="java -Dapple.awt.UIElement=true workflow"
else
	export JAVA="java workflow"
fi 
export CLASSPATH=$MBP
export WEKA="java "

NPROCS=1
OS=$(uname -s)

if [ "$OS" == "Linux" ]
then
	NPROCS=$(grep -c ^processor /proc/cpuinfo)
fi

if [ "$OS" == "Darwin" ]
then
	NPROCS=$(sysctl -n hw.ncpu)
fi

if [[ "$(uname)" == CYGWIN* ]]
then
	NPROCS=$(wmic cpu get NumberOfLogicalProcessors | sed -n -e '2{p;q}' | sed ':a;N;$!ba;y/\n/ /' | sed 's/ //g')
fi
echo "Requested operation mode: $3"

if [ "$3" == "s" ]
then
	NPROCS=1
	echo "Operation mode: single-threaded"
else
	if [ "$3" == "h" ]
	then
		NPROCS=$(($NPROCS/2))
		echo "Operation mode: utilize half of the CPU cores ($NPROCS)"
	else
		echo "Operation mode: utilize all CPU cores ($NPROCS detected)"
	fi
fi

export SYSTEM_cpu_n=$NPROCS

PARALLEL_EXECUTE="xargs -n1 -P$NPROCS -0 -I{}"