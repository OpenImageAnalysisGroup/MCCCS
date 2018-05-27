#!/bin/bash
#
# Extract class attribute list from ARFF file.
#
# (c) 2018 by C. Klukas
#
# input: stdin
# output: stdout
#
# exit code 0 - ok, output is given
# exit code 1 - not found, no output given
#
while IFS=$'\r' read -r line || [[ -n "$line" ]]
do
        if [[ "$line" = @* ]] && [[ $line = *class* ]] && [[ "$line" = *{* ]]
        then
                line=${line%*\}}
                line=${line#*\{}
                echo -n "$line"
                exit 0
        fi
done <&0 # read from stdin
exit 1
