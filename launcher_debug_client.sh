cd `dirname $0` &&\
git config core.filemode true &&\
git lfs install &&\
git fetch && git checkout debug && (git pull --ff-only origin debug || (git reset --hard && git pull -f --rebase --allow-unrelated-histories origin debug && git reset --hard && git clean -df)) &&\
(rm -rf client clients server servers || echo) &&\
./g4d -client
