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
        \"Email\": \"${FROM_EMAIL}\",
        \"Name\": \"${NAME}\"
      },
      \"To\": [
        {
          \"Email\": \"${TO_EMAIL}\",
          \"Name\": \"${NAME}\"
        }
      ],
      \"Subject\": \"${SUBJECT}\",
      \"TextPart\": \"Jenkins\",
      \"HTMLPart\": \"<p>Se ha realizado un push en la rama main que ha provocado la ejecución del workflow nombre_repositorio_workflow con los siguientes resultados:</p><p>Linter stage: ${status_linter}\",
      \"CustomID\": \"AppGettingStartedTest\"
    }
  ]
}"
