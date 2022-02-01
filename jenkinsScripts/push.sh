#!/bin/bash

echo AAAAAAAAAAA${3}
git remote set-url origin https://${1}:${3}@github.com/iferrer20/ghActions-Practica
git add .
git config --global user.name "${1}"
git config --global user.email "${1}@users.noreply.github.com"
git commit -m "${2}" --allow-empty
git push origin HEAD:jenkins
