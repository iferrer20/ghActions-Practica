# Table of contents
- [Práctica github actions](#práctica-github-actions)
  - [Preparación del linter](#preparación-del-linter)
  - [Preparación de cypress](#preparación-de-cypress)
  - [Preparación de badges](#preparación-de-badges)
  - [Deploy con vercel](#deploy-con-vercel)
  - [Envio de emails](#envio-de-emails)

# Práctica github actions

[![Cypress.io](https://img.shields.io/badge/tested%20with-Cypress-04C38E.svg)](https://www.cypress.io/)

## Introducción teórica
GitHub Actions es una herramienta que permite reducir la cadena de acciones necesarias para la ejecución de código, mediante la creación de un workflow responsable del Pipeline. Siendo configurable para que GitHub reaccione ante determinados eventos de forma automática según nuestras preferencias.

Por lo tanto, GitHub Actions le permite crear flujos de trabajo que se pueden usar para compilar, probar e implementar código. Además, brinda la posibilidad de crear flujos de integración y despliegue continuo dentro de nuestro repositorio.

![ghActions](https://img2.storyblok.com/672x0/f/79165/1200x630/ebb5571e69/github-action-01.png)

Actions usa paquetes de código en contenedores Docker, que se ejecutan en servidores GitHub y que, a su vez, son compatibles con cualquier lenguaje de programación. Esto hace que se ejecuten en servidores locales y nubes públicas.


## Preparación del linter
Fichero `.github/workflows/ghActions-Practica.yml`  
Nuevo job
```yaml
Linter_job:
  name: Linter job
  runs-on: ubuntu-latest

  steps:
    - name: Check out Git repository
      uses: actions/checkout@v2

    # Install your linters here
    - name: Run linters
      run: npm install && npm run lint
```

* El primer step se encarga de descargar el codigo fuente
* El segundo step se encarga de preparar el proyecto y iniciar el script lint verificando si el código de nuestra aplicación esta correctamente

Para solucionar los errores automáticamente del lint hay que ejecutar el siguiente comando. (Si sigue dando error se tiene que solucionar manualmente)
```sh
$ ./node_modules/.bin/next lint --fix
```


## Preparación de cypress
Fichero `.github/workflows/ghActions-Practica.yml`  
Nuevo job
```yaml
Cypress_job:
  name: Cypress job
  runs-on: ubuntu-latest
  needs: Linter_job
  steps:
    - name: Checkout
      uses: actions/checkout@v2

    - name: Cypress run
      uses: cypress-io/github-action@v2
      id: cypress
      continue-on-error: true
      with:
        config-file: cypress.json
        build: npm run build
        start: npm start
    
    - name: Outcome
      run: |
          echo ${{ steps.cypress.outcome }} > result.txt

    - name: Upload artifact
      uses: actions/upload-artifact@v2
      with:
        name: cypress-result
        path: result.txt
```

* El primer step se encarga de descargar el codigo fuente.
* El segundo se encarga de instalar nuestro proyecto y iniciarlo para luego ejecutar los tests de cypress, continue-on-error hará que continue los steps aunque de error, le ponemos id para obtener el resultado en el siguiente step.
* El tercero se encarga de obtener la salida del job anterior y guardarlo en result.txt.
* El ultimo step subirá el artefacto del fichero de la salida de cypress para obtenerlo en otro job.

## Preparación de badges
Fichero `.github/workflows/ghActions-Practica.yml`  
Nuevo job

```yaml
 Add_badge_job:
  name: Add badge job
  runs-on: ubuntu-latest
  needs: Cypress_job
  if: ${{ always() }}
  steps:
    - name: Checkout
      uses: actions/checkout@v2

    - name: Download artifact
      uses: actions/download-artifact@v2
      with:
        name: cypress-result

    - name: Cypress output
      id: cypress-output
      run: echo "::set-output name=cypress_outcome::$(cat result.txt)"

    - uses: ./.github/actions/badges/
      with:
        cypress_outcome: ${{ steps.cypress-output.outputs.cypress_outcome }}

    - name: Commit
      run: |
        git config user.email "badgebot@github.com"
        git config user.name "badgebot"
        git add .
        git commit --allow-empty -m "Badges"
        git remote set-url origin https://iferrer20:${{ secrets.GITHUB_TOKEN }}@github.com/iferrer20/ghActions-Practica.git
        git push
```

Este job se ejecutara aunque los jobs anteriores fallen. Contiene los siguientes steps.
* El primer step se encarga de descargar el codigo fuente.
* EL segundo step se encarga de descargar el artefacto subido en el job anterior (results.txt).
* El tercero se encarga de establecer como salida el artefacto results.txt.
* El cuarto se encarga de ejecutar nuestro action badge, tiene un solo argumento que indica el status de cypress (si ha fallado o no).
* El ultimo step se encargará de subir los cambios hechos por nuestro badge al repositorio remoto.

### Action badges
Fichero `./.github/actions/badges/action.yml`
```yaml
name: 'Badges'
description: 'Set badges in readme file'
inputs:
  cypress_outcome:
    description: 'Cypress outcome'
    required: true
runs:
  using: "composite"
  steps:
    - run: python ${{ github.action_path }}/badges.py ${{ inputs.cypress_outcome }}
      shell: bash
```

Este action tomará como input cypress_outcome que indicará si cypress ha fallado o no, y será obligatorio.  
El action corre sobre composite que nos permite añadir steps y ejecutar python, ponemos shell bash para poder ejecutar el comando python sobre el script `badges.py` y le añadimos como argumento el cypress outcome

Fichero `./.github/actions/badges/badges.py`
```python
import sys
import re

content = open("README.md").read()
f = open("README.md", "w")
f.write(
    re.sub('|', '' if sys.argv[1] == "success" else '', content)
)
f.close()
```

Dependiendo de si el primer argumento es success, el script substituirá el uri que indica el tipo de badge, y lo guardará al README.md

## Deploy con vercel
Fichero `.github/workflows/ghActions-Practica.yml`  
Nuevo job
```yaml
Deploy_job:
  name: Deploy job
  runs-on: ubuntu-latest
  needs: Cypress_job
  steps:
    - name: Checkout
      uses: actions/checkout@v2

    - name: Vercel deployment
      uses: amondnet/vercel-action@v20
      with:
        vercel-token: ${{ secrets.VERCEL_TOKEN }}
        github-token: ${{ secrets.GITHUB_TOKEN }}
        vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
        vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
```


* El primer step se encargará de obtener el código fuente de nuestro repositorio remoto
* El segundo step se encargará del deploy nuestro proyecto en vercel, dentro de with ponemos todos los tokens mencionados

Necesitaremos poner 3 tokens en los secrets, el `VERCEL_TOKEN` `VERCEL_PROJECT_ID` y `VERCEL_ORG_ID`
El token `VERCEL_TOKEN` es un token que tendremos que generar en settings->tokens  
El token `VERCEL_ORG_ID` es nuestro user id lo podemos conseguir entrando a nuestro perfil  
El token `VERCEL_PROJECT_ID` está en settings de nuestro proyecto  

![alt text](https://github.com/iferrer20/ghActions-Practica/blob/main/readme/vercel_token.png?raw=true)

## Envio de emails
Fichero `.github/workflows/ghActions-Practica.yml`  
Nuevo job
```yaml
Notification_job:
  name: Notification job
  runs-on: ubuntu-latest
  needs: [Deploy_job, Cypress_job, Linter_job, Add_badge_job]
  if: ${{ always() }}
  steps:
    - name: Checkout
      uses: actions/checkout@v2

    - name: Send email
      uses: ./.github/actions/email/
      with:
        text: 'Se ha realizado un push en la rama main que ha provocado la ejecución del workflow nombre_repositorio_workflow con los siguientes resultados<br><br>Linter_job: ${{ needs.Linter_job.result }}<br>Cypress_job: ${{ needs.Cypress_job.result }}<br>Badges_job: ${{ needs.Add_badge_job.result }}<br>Deploy_job: ${{ needs.Deploy_job.result }}'
        from_email: "iferreriestacio@gmail.com"
        to_email: "iferreriestacio@gmail.com"
        name: ${{ github.event.pusher.name }}
        subject: 'Re: ${{ github.event.head_commit.message }} Resultado del workflow ejecutado'
        mailjet_api_key: ${{ secrets.MAILJET_API_KEY }}
        mailjet_secret_key: ${{ secrets.MAILJET_SECRET_KEY }}
```
Este job se ejecutará siempre no importando el qué, y depende de una lista de jobs para poder obtener sus resultados 
* El segundo step se encargará de ejecutar un action personalizado que enviará un email a través de mailjet, tenemos que establecer las claves de mailjet en los secrets y dentro de with indicamos los parametros para enviar el correo.

### Action email

Este fichero describe los parametros y el comando que ejecutará el action email
Fichero `.github/actions/email/action.yml`
```yaml
name: 'Email'
description: 'Send email to the pusher'
inputs:
  text:
    description: 'Email text message'
    required: true

  from_email:
    description: 'From email'
    required: true

  to_email:
    description: 'Email destination target'
    required: true

  name:
    description: 'Name'
    required: true

  subject:
    description: 'Subject'
    required: true

  mailjet_api_key:
    description: 'Api key'
    required: true

  mailjet_secret_key:
    description: 'Secret key'
    required: true

runs:
  using: 'composite'
  steps:
    - run: MAILJET_API_KEY="${{ inputs.mailjet_api_key }}" MAILJET_SECRET_KEY="${{ inputs.mailjet_secret_key }}" TEXT="${{ inputs.text }}" FROM_EMAIL="${{ inputs.from_email }}" TO_EMAIL="${{ inputs.to_email }}" NAME="${{ inputs.name }}" SUBJECT="${{ inputs.subject }}" bash ${{ github.action_path }}/email.sh 
      shell: bash
```

Ejecutará el script email.sh definiendo todas las variables de input a variables de entorno 
El script esta hecho con bash, simplemente hace un POST con el comando curl, pasando todas las variables de entorno al json

```bash
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
```

Cuando se ejecute el action, se enviará el siguiente mensaje al correo electrónico

![alt text](https://github.com/iferrer20/ghActions-Practica/blob/main/readme/email_message.png?raw=true)
