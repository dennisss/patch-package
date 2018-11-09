# make sure errors stop the script
set -e

alias patch-package="./node_modules/.bin/patch-package"
alias replace="./node_modules/.bin/replace"

echo "add patch-package"
yarn add $1

echo "SNAPSHOT: left-pad typings should contain patch-package"
grep patch-package node_modules/@types/left-pad/index.d.ts
echo "END SNAPSHOT"

echo "modify add.d.t.s"
replace add patch-package node_modules/@types/lodash/add.d.ts

echo "patch-package can make patches for scoped packages"
patch-package @types/lodash

echo "remove node_modules"
rimraf node_modules

echo "reinstall node_modules"
yarn

echo "SNAPSHOT: add.d.ts should contain patch-package"
grep patch-package node_modules/@types/lodash/add.d.ts
echo "END SNAPSHOT"