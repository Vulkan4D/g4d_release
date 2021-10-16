cd `dirname $0` &&\
git config core.filemode false &&\
git lfs install &&\
git fetch && git checkout master && (git pull --ff-only origin master || (git reset --hard && git pull -f --rebase --allow-unrelated-histories origin master && git reset --hard && git clean -df)) &&\
chmod 777 g4d &&\
rm -rf client clients server servers
./g4d -client
