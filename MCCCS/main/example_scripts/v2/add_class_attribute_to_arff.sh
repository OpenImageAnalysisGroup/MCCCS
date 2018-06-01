#!/bin/bash
if [ "$#" -ne 1 ] || [[ $1 = "/?" ]] || [[ ${1,,} == /h* ]]
then
        echo "MCCCS V2 (c) 2018 by C. Klukas"
        echo "------------------------------"
        echo "Add class attribute to list of attributes of ARFF file. Data rows are extended with '?'-values."
        echo
        echo "Usage:"
        echo "Parameter 1 - list of class names (e.g. 'class1,class2,class3')"
        echo "Input       - stdin (redirect if needed)"
        echo "Output      - stdout (redirect if needed)"
        exit 1
fi
while IFS=$'\r' read -r line || [[ -n "$line" ]];
do
        if [[ "${line,,}" = @data* ]]
        then
                echo "@attribute class {$1}"
                echo "$line"
                break
        else
                if ! [ -z "$line" ]
                then
                        echo "$line"
                fi
        fi
done <&0
grep -v @ <&0 | grep . | grep -v % | sed  "s/.*/&,?/"
echo "%"
