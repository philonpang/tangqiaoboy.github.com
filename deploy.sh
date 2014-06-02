#! /bin/bash

rake deploy
cd _deploy

# add gitcafe source
git remote add gitcafe git@gitcafe.com:tangqiaoboy/tangqiaoboy.git >> /dev/null 2>&1
echo "### Pushing to GitCafe..."
git push gitcafe master:gitcafe-pages
echo "### Done"