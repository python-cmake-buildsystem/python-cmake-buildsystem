
for new upstream

git checkout upstream
git pull

git checkout support-build-37-and-38-rebased
git rebase -i upstream
git push -f

git checkout upgrade-py376
git rebase -i support-build-37-and-38-rebased
git push -f

git checkout ci-376
git rebase -i upgrade-py376
git push -f

git checkout master
git rebase -i ci-376
git push -f

ci-376 - been pushing this to CI
   https://ci.appveyor.com/project/dand-oss/python-cmake-buildsystem
   https://travis-ci.org/dand-oss/python-cmake-buildsystem

upgrade-py376 - pull request to upstream

3.8.1 - work branch for getting to 3.8

3.6.10 - working 3.6 branch

cmake-3.7.6 - old branch

master-3.7.6 - old branch
