#!/bin/bash

env

curl -s \
-X POST \
--user "${MAILJET_API_KEY}:${MAILJET_SECRET_KEY}" \
https://api.mailjet.com/v3.1/send \
-H 'Content-Type: application/json' \
-d "{
  \"Messages\":[
    {
      \"From\": {
        \"Email\": \"iferreriestacio@gmail.com\",
        \"Name\": \"iferrer20\"
      },
      \"To\": [
        {
          \"Email\": \"${TO_EMAIL}\",
          \"Name\": \"Ejecución por ${EXECUTOR}\"
        }
      ],
      \"Subject\": \"${SUBJECT}\",
      \"TextPart\": \"Jenkins\",
      \"HTMLPart\": \"<p>Se ha realizado un push en la rama main que ha provocado la ejecución del workflow nombre_repositorio_workflow con los siguientes resultados:<br>Linter stage: ${status_lint}<br>Test stage: ${status_tests}<br>Update readme: ${status_update}<br>Deploy to vercel: ${status_vercel}</p>\",
      \"CustomID\": \"AppGettingStartedTest\"
    }
  ]
}"
