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

### ping.smart.sh ###

> ping [--rotate n] [--timeout n] [--tmp path_to_tmp] [--color-off] address1 address2 ...

ping several address at the same time

```
# ping all DigitalOcean regions
cat << EOF | bash
./ping.smart.sh \
--timeout 1 \
--rotate 10 \
 speedtest-ams1.digitalocean.com \
 speedtest-lon1.digitalocean.com \
 speedtest-nyc3.digitalocean.com \
 speedtest-ams2.digitalocean.com \
 speedtest-ny1.digitalocean.com \
 speedtest-sfo1.digitalocean.com \
 speedtest-ams3.digitalocean.com \
 speedtest-nyc2.digitalocean.com \
 speedtest-sgp1.digitalocean.com
```

### sync.libs.sh ###

copy/sync shell-scripts libs to other folder (force)
