#!/bin/bash

echo AAAAAAAAAAA${TOKEN}
git remote set-url origin https://iferrer20:${TOKEN}@github.com/iferrer20/ghActions-Practica
git add .
git config --global user.name "iferrer20"
git config --global user.email "iferrer20@users.noreply.github.com"
git commit -m "jenkins_autocomit" --allow-empty
git push origin HEAD:jenkins
