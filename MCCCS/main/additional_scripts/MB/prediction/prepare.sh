APPPATH=$(realpath $1)
export MBP="$APPPATH/mcccs.jar:$APPPATH/lib/iap.jar:$APPPATH/lib/JFeatureLib-1.6.1-jar-with-dependencies.jar"
cd "$2"
echo "Delete files:"
echo "'all_results.csv', 'all_fgbg.arff', 'all_disease.arff',"
echo "'fgbgClassifier.data', 'diseaseClassifier.data', 'fgbg.model'"
#rm -f all_results.csv
rm -f all_fgbg.arff
rm -f all_label.arff
rm -f fgbgTraining.arff
rm -f labelTraining.arff
rm -f fgbg.model
rm -f label.model
if [[ "$(uname)" == CYGWIN* ]]
then
	MBP=$(cygpath -mp $MBP)
fi
if [ "$(uname)" == "Darwin" ]; then
	export JAVA="/mnt/16TB_1/jdk1.8.0_45/jre/bin/java -Xmx10g -Dapple.awt.UIElement=true -cp $MBP workflow"
else
	export JAVA="/mnt/16TB_1/jdk1.8.0_45/jre/bin/java -Xmx10g -cp $MBP workflow"
fi 
WEKAJAR=$APPPATH/lib/weka.jar
if [[ "$(uname)" == CYGWIN* ]]
then
	WEKAJAR=$(cygpath -wp $WEKAJAR)
fi
export WEKA="/mnt/16TB_1/jdk1.8.0_45/jre/bin/java -Xmx10g -cp $WEKAJAR"

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
echo "Requested Operation Mode: $3"
if [ "$3" == "s" ];
then
	NPROCS=1
	echo "Operation Mode: single-threaded"
else
	if [ "$3" == "h" ];
	then
		NPROCS=$(echo "$NPROCS/2" | bc)
		echo "Operation Mode: utilizing half number of CPUs ($NPROCS)"
	else
		if [ "$3" == "2" ];
		then
			NPROCS=30
			echo "Operation Mode: utilizing 2 CPUs ($NPROCS)"
		else
			echo "Operation Mode: multi-threaded ($NPROCS CPUs detected)"
		fi
	fi
fi

export SYSTEM_cpu_n=$NPROCS

#if parallel is not installed use xargs instead:
par="/opt/Bio/parallel/20160322/bin/parallel --gnu --tmpdir /mnt/16TB_1/MCCCS_MB0005-5/tmp/ --eta --memfree 5G --delay 1 -j $NPROCS"
#type parallel >/dev/null 2>&1 ||  
#par="xargs -n1 -P$NPROCS -I{}" 
echo "Parallel command: $par"
