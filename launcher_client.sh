cd `dirname $0` &&\
git config core.filemode true &&\
git lfs install &&\
git fetch && git checkout master && (git pull --ff-only origin master || (git reset --hard && git pull -f --rebase --allow-unrelated-histories origin master && git reset --hard && git clean -df)) &&\
(rm -rf client clients server servers || echo) &&\
./g4d -client
