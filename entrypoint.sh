#!/bin/sh
echo '=================== Install Hugo ==================='
DOWNLOAD_HUGO_VERSION=${HUGO_VERSION:-0.54.0}
GITHUB_DEPLOY_REPOSITORY=${GITHUB_REMOTE_REPOSITORY:-$GITHUB_REPOSITORY}
echo "Installing Hugo $DOWNLOAD_HUGO_VERSION"
wget -O /tmp/hugo.tar.gz https://github.com/gohugoio/hugo/releases/download/v${DOWNLOAD_HUGO_VERSION}/hugo_extended_${DOWNLOAD_HUGO_VERSION}_Linux-64bit.tar.gz &&\
tar -zxf /tmp/hugo.tar.gz -C /tmp &&\
mv /tmp/hugo /usr/local/bin/hugo &&\
rm /tmp/*
echo '=================== Create deploy key to push ==================='
mkdir /root/.ssh
ssh-keyscan -t rsa github.com > /root/.ssh/known_hosts && \
echo "${GIT_DEPLOY_KEY}" > /root/.ssh/id_rsa && \
chmod 400 /root/.ssh/id_rsa
echo '=================== Build site ==================='
cd static/marketing-site/
git submodule add -b master git@github.com:conifersoftware/conifersoftware.github.io.git public
HUGO_ENV=production hugo -v --minify
echo '=================== Publish to GitHub Pages ==================='
cd public
remote_repo="git@github.com:${GITHUB_DEPLOY_REPOSITORY}.git" && \
remote_branch=master && \
echo "Pushing Builds to $remote_repo:$remote_branch" && \
git init && \
git remote add deploy $remote_repo && \
git checkout $remote_branch || git checkout --orphan $remote_branch && \
git config user.name "${GITHUB_ACTOR}" && \
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com" && \
git add . && \
echo -n 'Files to Commit:' && ls -l | wc -l && \
timestamp=$(date +%s%3N) && \
git commit -m "Automated deployment to GitHub Pages on $timestamp" > /dev/null 2>&1 && \
git push deploy $remote_branch --force && \
rm -fr .git && \
cd ../
echo '=================== Done  ==================='
