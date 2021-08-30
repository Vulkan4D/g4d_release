cd `dirname $0` &&\
git config core.filemode false &&\
git lfs install &&\
(git pull --ff-only origin master || (git reset --hard && git pull -f --rebase --allow-unrelated-histories origin master && git reset --hard && git clean -df)) &&\
chmod +x ./g4d &&\
./g4d
