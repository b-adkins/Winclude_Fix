#!/usr/bin/env bash

# Run in the trunk directory checked out of SVN!
export ERR_FILE=`readlink -f $1`

WD=`pwd`
PROJECT_NAME=$2
PROJECT_ROOT=`find .. -name $PROJECT_NAME -type d | xargs readlink -f`
echo "Found \"branch\" directory \"$PROJECT_ROOT\""

# Files that contain a broken include
# Sed saves everything containing path-characters from beginning of line to first :
export CODE_FILES=`cat $ERR_FILE | grep 'No such file or directory' | sed 's~^\([a-zA-Z0-9\\/.\_]*\):[0-9]*.*$~\1~'`
export CODE_FILES=`for f in $CODE_FILES; do readlink -f $f; done`


# Special shell scripting variable
#set -- $CODE_FILES

for CODE_FILE in `echo $CODE_FILES | awk '{print $0}'`; do
#  CODE_FILE=$2
  FDIR=`dirname $CODE_FILE`
  cd $FDIR
  echo "Searching for bad includes in \"$CODE_FILE\""

  # The included path itself
  # Grep regex only detects $CODE_FILE on the left side of the error message (i.e. $CODE_FILE is the includer, not the includee!)
  # This time, sed saves what is between the last : and ": No such file or directory"
  export WIN_INCLUDES=`cat $ERR_FILE | grep "No such file or directory" | grep "^[a-zA-Z0-9:\\/.\_]*$(basename $CODE_FILE)" | sed 's~^.*fatal error: \([a-zA-Z0-9\\/.\_]*\): No such file or directory.*$~\1~' | sort | uniq`

  # Convert to linux eqivalent
  for WIN_INCLUDE in $(echo $WIN_INCLUDES | tr '\\' '/' ); do
    # Strip all leading ".." and "../"
    WIN_INCLUDE_BASE=`echo $WIN_INCLUDE | sed 's!\.\.[/\\]!!g'`
    export LIN_PATH=`find $PROJECT_ROOT -iwholename "*$WIN_INCLUDE"`
    export LIN_INCLUDE=`echo $LIN_PATH | sed "s!$PROJECT_ROOT[/]*[a-zA-Z_\-]*/!!"`
#    echo $WIN_INCLUDE "->" $LIN_PATH "->" $LIN_INCLUDE
    echo $WIN_INCLUDE "->" $LIN_INCLUDE
    sed 's/$WIN_INCLUDE/$LIN_INCLUDE/' $CODE_FILE | grep '"$LIN_INCLUDE"'
  done

  cd $PROJECT_ROOT

done

cd $WD
