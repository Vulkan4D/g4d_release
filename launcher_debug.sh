cd `dirname $0` &&\
git config core.filemode false &&\
git lfs install &&\
git fetch && git checkout debug && (git pull --ff-only origin debug || (git reset --hard && git pull -f --rebase --allow-unrelated-histories origin debug && git reset --hard && git clean -df)) &&\
chmod 777 g4d &&\
./g4d
