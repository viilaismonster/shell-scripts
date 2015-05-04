shell-scripts
=============

scripts for easy using shell


## suggested alias ##

> alias git=~/tool/shell-scripts/git.smart.sh

> alias ssh=~/tool/shell-scripts/ssh.smart.sh

### git.multi.sh ###

git extension for multi repositories situation

> git (all|each) (xpush|xpull|commit) [args]

currently I am working with a project with so many repos to commit in the same time,
and each time when I want to make a commit, I need to cd into a folder, then commit, then push, then cd -, then switch to next folder.

so I write this extension:

for folder structure like

/project/  
/project/mod1  
/project/mod2  
/project/mod3  

```
git all xpull
git all commit
git all xpush
```

also, when you don't want to push all folder, use git each [args] instead

```
git each xpull mod2 mod3
git each commit mod2 mod3 
git all xpush
```

### git.smart.sh ###

> git xpush

push to every remote

> git xpull

default pull current branch from origin

> git ca

git commit -am

> git remotes

show all remotes in list


### ssh.smart.sh ###

> ssh --bench ADDRESS --timeout TIMEOUT --repeats REPEAT_TIMES

test if ssh to server stable


### sync.libs.sh ###

copy/sync shell-scripts libs to other folder (force)
