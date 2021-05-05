#!/bin/bash

function _info(){
    echo -e "\033[32m$1\033[0m"
}

function _warning(){
    echo -e "\033[33m$1\033[0m"
}

function _error(){
    echo -e "\033[31m$1\033[0m"
}

function _green(){
	echo "\033[32m"$1"\033[0m"
}

function _cyan(){
	echo "\033[36m"$1"\033[0m"
}

function _blue(){
	echo "\033[34m"$1"\033[0m"
}

function _magenta(){
	echo "\033[35m"$1"\033[0m"
}

function _grey(){
	echo "\033[37m"$1"\033[0m"
}

function _yellow(){
	echo "\033[33m"$1"\033[0m"
}

function _red(){
	echo "\033[31m"$1"\033[0m"
}

# 确保脚本抛出遇到的错误
set -e

_info '
-------------------------------------
把当前项目拷贝到 blog 同步脚本
-------------------------------------
'


rsync -av --exclude  .git/ --exclude  .gitignore --exclude  LICENSE --exclude  .vscode/ --exclude  vue3-project/ --exclude shells/  .  ../blog/docs/open-in-editor

echo

cd ../blog/

# git
git pull
git status
git add docs/open-in-editor
# git commit -m "update: docs/open-in-editor 同步 open-in-editor :construction:"
# git push
# git status


echo

_info '
-------------------------------------
同步完成，并提交到远程仓库
-------------------------------------
'
cd -