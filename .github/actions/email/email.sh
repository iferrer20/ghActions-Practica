#!/bin/bash

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
      \"TextPart\": \"${TEXT}\",
      \"HTMLPart\": \"${TEXT}\",
      \"CustomID\": \"AppGettingStartedTest\"
    }
  ]
}"

