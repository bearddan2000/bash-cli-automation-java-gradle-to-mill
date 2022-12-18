#! /bin/bash

for d in `ls -la | grep ^d | awk '{print $NF}' | egrep -v '^\.'`; do

  ./readme.sh $d "Spring"

  ./build.sh $d
#
  ./folder.sh $d

done
