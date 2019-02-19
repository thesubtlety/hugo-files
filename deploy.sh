#!/bin/bash

# in ./hugo-files
#hugo new post/postname
#hugo server --theme=hyde --buildDrafts
#hugo undraft content/post/postname.markdown
#./deploy
# note hugo-files/public is a sub repo which is pushed to the thesubtlety.github.io repo


msg="rebuild site"

echo -e "Deploying to Github\n"
echo "Are you sure you want to do this?" && sleep 5

echo -e "Building site..."
hugo --theme=hyde

cd public
git pull origin master
echo "Adding CNAME..."
echo "www.thesubtlety.com" > CNAME
echo "Gitting public pages stuff..."
git add -A
git commit -m "$msg"
git push origin master
cd ..

git pull origin master
echo "Gitting hugo-pages stuff..."
git add -A
git commit -m "$msg"
git push origin master

echo "Done"
