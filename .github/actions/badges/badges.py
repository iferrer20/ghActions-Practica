import sys
import re

content = open("README.md").read()
f = open("README.md", "w")
f.write(
    re.sub('tested%20with-Cypress-04C38E|test-failure-red', 'tested%20with-Cypress-04C38E' if sys.argv[1] == "success" else 'test-failure-red', content)
)
f.close()
