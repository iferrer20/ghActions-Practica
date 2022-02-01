#!/bin/bash

echo AAAAAAAAAAA${2}
git remote set-url origin https://iferrer20:${2}@github.com/iferrer20/ghActions-Practica
git add .
git config --global user.name "iferrer20"
git config --global user.email "iferrer20@users.noreply.github.com"
git commit -m "Jenkins update readme" --allow-empty
git push origin HEAD:jenkins
