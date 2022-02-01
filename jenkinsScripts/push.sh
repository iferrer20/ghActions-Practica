#!/bin/bash

git add .
git --global user.name "iferrer20"
git --global user.email "iferrer20@users.noreply.github.com"
git commit -m "Jenkins update readme"
git push origin HEAD:jenkins
