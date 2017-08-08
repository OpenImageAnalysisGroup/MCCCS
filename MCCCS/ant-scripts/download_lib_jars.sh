#!/bin/bash
cd $(dirname $0)
echo "Current directory: $(pwd)"
echo "Start ant task with enabled autoproxy-setting..."
ANT_ARGS="-autoproxy"
ant -f ./download_lib_jars.xml
