#!/bin/bash
curDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
extensionDirs="extensions arc-extensions"
rm $curDir/validations/*
validationFile=$curDir/validations/fydeos-default-apps-1.0.0.validation
touch  $validationFile
for ext in $extensionDirs ; do
  cd $curDir/$ext
  for file in `ls *.crx` ; do
   sha256sum $file >> $validationFile;
  done
  cd .. 
done



