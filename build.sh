#! /bin/bash
function cp_build_file() {
  #statements
  local src=$1
  local target=$2

  #get the springBootVersion
  local version=`cat $src | grep springBootVersion | awk '{printf "%s", $3}' | sed "s/'//g"`

  #1. grep for only implementation
  #2. sort by artifact
  #3. remove single quotes replace with double
  #4. replace implementation with ivy
  for x in `cat $src | grep implementation | sort -k2 | sed "s/'/\"/g" | sed "s/implementation /ivy/g"`; do

    #test if there's a version number
    if [[ `echo $x | awk -F ':' '{print NF}'` -lt 3 ]]; then

      #add version number
      x=`echo $x | sed "s/\"$/:$version\"/g"`

    fi

    #insert into target at line 7
    sed -i "7 i $x" $target

  done

  #grep for only ivy and end with quote
  for x in `cat $target | grep ivy | egrep '"$'`; do

    #add comma
    sed -i "s/$x/$x,/g" $target

  done

  #1. reverse file
  #2. remove forst comma
  tac $target > tmp
  perl -pi.bac -0 -e "s/,//" tmp
  tac tmp > $target
  rm -Rf tmp tmp.bac
}
function rm_Dockerfile() {
  #statements
  local parent=$(pwd)
  local target=$1

  #change to bin dir
  cd $target

  #go up one level
  cd ../

  #remove Dockerfile if exists in prj_dir
  if [[ -e ./Dockerfile ]]; then
    #statements
    rm -f ./Dockerfile

    #copy Dockerfile from .src
    cp $parent/.src/Dockerfile .

  fi

  #switch baxk to project dir
  cd $parent
}

function create_mill_wrkspace() {
  #statements

  local prj_dir=$1
  local tmp_dir=$2
  local build="build.sc"

  #copy WORKSPACE file from src folder
  cp .src/$build $tmp_dir/build.sc

  cp_build_file $tmp_dir/build.gradle $tmp_dir/build.sc

  rm -f $tmp_dir/build.gradle

  rm_Dockerfile $tmp_dir

  mkdir $tmp_dir/Spring

  mv $tmp_dir/src $tmp_dir/Spring
}

d=$1

for e in `find $d -type d -name bin`; do

  #statements
  create_mill_wrkspace $d $e
done
