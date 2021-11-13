set gitdir=%~dp0gitbin
set path=%gitdir%\bin;%path%
pushd %~dp0 && git.exe config core.filemode false && git-lfs.exe install && git.exe fetch && git.exe checkout debug && (git-pull.exe --ff-only origin debug || (git.exe reset --hard && git-pull.exe -f --rebase --allow-unrelated-histories origin debug && git.exe reset --hard && git-clean.exe -df)) && start g4d.exe || pause
