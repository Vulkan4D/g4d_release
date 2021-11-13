cd `dirname $0`
rm -rf * .git*
git init --initial-branch=master
git config core.filemode true
git lfs install
git remote add origin https://github.com/Vulkan4D/g4d_release.git
git pull origin master
