#!/bin/bash

x=""
if [ $status_tests -eq 0 ]; then
  x="tested%20with-Cypress-04C38E"
else
  x="test-failure-red"
fi

sed -i -E "s/(test-failure-red|tested%20with-Cypress-04C38E)/${x}/g" ./README.md
