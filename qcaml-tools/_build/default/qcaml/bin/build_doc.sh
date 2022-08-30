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

CONFIG="--load docs/htmlize.el --load docs/config.el"
if [[ ${DIR} == "docs" ]] ; then

  emacs --debug-init --batch $CONFIG docs/index.org -f org-html-export-to-html 

else
  rm -f docs/${DIR}.org
  for i in ${DIR}/README.org ${DIR}/[a-z]*.org
  do
          cat $i >> docs/${DIR}.org
  done

  emacs --debug-init --batch $CONFIG docs/${DIR}.org -f org-html-export-to-html \
  && rm docs/${DIR}.org
fi



