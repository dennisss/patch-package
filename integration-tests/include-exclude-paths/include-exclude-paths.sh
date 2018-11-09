# make sure errors stop the script
set -e

alias patch-package="./node_modules/.bin/patch-package"
alias replace="./node_modules/.bin/replace"

echo "add patch-package"
yarn add $1

echo "edit some files"
replace exports patchPackage node_modules/lodash/_baseClamp.js
replace exports patchPackage node_modules/lodash/_baseClone.js
replace exports patchPackage node_modules/lodash/flip.js

echo "add a file"
echo "this is a new file" > node_modules/lodash/newFile.md

echo "remove a file"
rm node_modules/lodash/fp/__.js

echo "run patch-package with only __.js included"
patch-package lodash --include __

echo "SNAPSHOT: only __.js being deleted"
cat patches/lodash*
echo "END SNAPSHOT"

echo "run patch-package excluding the base files"
patch-package lodash --exclude base

echo "SNAPSHOT: no base files"
cat patches/lodash*
echo "END SNAPSHOT"

echo "run patch-package including base and excluding clone"
patch-package lodash --include base --exclude clone

echo "SNAPSHOT: only base files, no clone files"
cat patches/lodash*
echo "END SNAPSHOT"

echo "run patch package excluding all but flip"
patch-package lodash --exclude '^(?!.*flip)'

echo "SNAPSHOT: exclude all but flip"
cat patches/lodash*
echo "END SNAPSHOT"

echo "run patch package including newfile (case insensitive)"
patch-package lodash --include newfile

echo "run patch package including newfile (case sensitive)"
if patch-package lodash --include newfile --case-sensitive-path-filtering
then
  exit 1
fi

echo "run patch package including newFile (case insensitive)"
patch-package lodash --include newFile --case-sensitive-path-filtering

echo "revet to the beginning"
rimraf node_modules
yarn

echo "edit lodash's package.json"
replace description patchPackageRulezLol node_modules/lodash/package.json

echo "check that the edit was ignored by default"
if patch-package lodash
then
  exit 1
fi

echo "un-ingore the edit by specifying the empty string as regexp"
patch-package lodash --exclude '^$'

echo "SNAPSHOT: modified package.json"
cat patches/lodash*
echo "END SNAPSHOT"
