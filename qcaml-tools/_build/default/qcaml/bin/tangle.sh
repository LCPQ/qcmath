#!/bin/bash
# Usage: $0 [DIR]

if [[ -z $1 ]] ; then
        echo "Usage: $0 [DIR]"
        exit -1
fi


if [[ $(basename $PWD) != "QCaml" ]] ; then
        echo "This script needs to be run in the QCaml directory"
        exit -1
fi

DIR=${1%/}

cd $DIR

for i in *.org
do
        echo "--- $i ----"
        emacs --batch ./$i --load=../docs/config_tangle.el -f org-babel-tangle
done

