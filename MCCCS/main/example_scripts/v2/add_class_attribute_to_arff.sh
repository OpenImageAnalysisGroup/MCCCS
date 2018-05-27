#!/bin/bash
#
# Add class attribute to list of attributes of ARFF file. Data rows are extended with '?'-values.
#
# (c) 2018 by C. Klukas
#
# input: stdin
# output: stdout
# param 1: list of class names (e.g. "class1,class2,class3")
#
# remark: empty lines are not included in output
IN_DATA=false
while IFS=$'\r' read -r line || [[ -n "$line" ]];
do
        if ! [ "$line" = "" ]
        then
                if [ $IN_DATA = true ]
                then
                        if ! [[ "$line" = %* ]]
                        then
                                echo "$line,?"
                        else
                                echo "$line"
                                IN_DATA=false
                        fi
                else
                        if [[ "$line" = @DATA* ]]
                        then
                                echo "@ATTRIBUTE class {$1}"
                                echo "$line"
                                IN_DATA=true
                        else
                                echo "$line"
                        fi
                fi
        fi
done <&0 # read from stdin
