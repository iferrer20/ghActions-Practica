# Table of contents
- [Práctica github actions](#pr-ctica-github-actions)
  * [Introducción teórica](#introducci-n-te-rica)
  * [Params (0,5)](#params--0-5-)
  * [PollSCM (0,2)](#pollscm--0-2-)
  * [Stage linter (1,0)](#stage-linter--1-0-)
  * [Stage Test (1,0)](#stage-test--1-0-)
  * [Stage Update readme (1,0)](#stage-update-readme--1-0-)
  * [Stage Push_Changes (1,0)](#stage-push-changes--1-0-)
  * [Stage deploy_to_vercel (1,5)](#stage-deploy-to-vercel--1-5-)
  * [Stage notification (1,0)](#stage-notification--1-0-)

# Práctica github actions

[![Cypress.io](https://img.shields.io/badge/tested%20with-Cypress-04C38E.svg)](https://www.cypress.io/)

## Introducción teórica

Jenkins es una herramienta de automatización de código abierto escrita en Java con complementos creados para fines de integración continua. Jenkins se utiliza para crear y probar sus proyectos de software continuamente, lo que facilita a los desarrolladores la integración de cambios en el proyecto y facilita a los usuarios obtener una nueva compilación. También le permite entregar su software continuamente al integrarse con una gran cantidad de tecnologías de prueba e implementación.  

Con Jenkins, las organizaciones pueden acelerar el proceso de desarrollo de software a través de la automatización. Jenkins integra procesos de ciclo de vida de desarrollo de todo tipo, incluidos compilación, documentación, prueba, paquete, etapa, implementación, análisis estático y mucho más.  

Jenkins logra la integración continua con la ayuda de complementos. Los complementos permiten la integración de varias etapas de DevOps. Si desea integrar una herramienta en particular, debe instalar los complementos para esa herramienta. Por ejemplo, Git, proyecto Maven 2, Amazon EC2, editor HTML, etc.  


![jenkins](https://ricardogeek.com/wp-content/uploads/2018/06/jenkins-ci_512.png)

## Params (0,5)

En el Jenkinsfile dentro de la pipeline declaro 3 parametros 

```groovy
parameters {
    string(name: 'ejecutor', description: 'Ejecutor')
    string(name: 'motivo', description: 'Motivo')
    string(name: 'correo', description: 'Correo notificación')
}
```

## PollSCM (0,2)

Dentro de la pipeline uso pollSCM para que cada 3 horas compruebe si hay un cambio
```groovy
triggers {
    pollSCM('1 */3 * * *')
}
```

## Stage linter (1,0)

Este es el stage linter que se encarga de iniciar el lint con npm y retornar su estado guardandolo en la variable status_lint (en el env)

```groovy
stage('Linter') {
    steps {
        script {
            env.status_lint = sh(script: "npm run lint", returnStatus: true)
        }
    }
}
```

##  Stage Test (1,0)

Este es el stage test, iniciará el servidor en modo dev en segundo plano, y luego ejecuta los tests de cypress. El resultado del comando npm se guardará en status_tests gracias a returnStatus: true

```groovy
stage('Test') {
    steps {
        sh 'npm run dev &'
        script {
            env.status_tests = sh(script: "npm run cypress", returnStatus: true)
        }
    }
}

```


## Stage Update readme (1,0)

El stage update en el archivo Jenkinsfile ejecutará el script `jenkinsScripts/readme.sh` 
Como he definido la variable status_tests dentro de env no hará falta pasar parametros al script

```groovy
stage('Update_Readme') {
    steps {
        script {
            env.status_update = sh(script: "jenkinsScripts/readme.sh", returnStatus: true)
        }
    }
}
```

El script se encargará de ver la variable de entorno status_tests y remplazará el README.md con un simple sed.

```bash
#!/bin/bash

x=""
if [ $status_tests -eq 0 ]; then
  x="tested%20with-Cypress-04C38E"
else
  x="test-failure-red"
fi

sed -i -E "s/(test-failure-red|tested%20with-Cypress-04C38E)/${x}/g" ./README.md
```

## Stage Push_Changes (1,0)

El push changes se encargará de subir los cambios del readme al repositorio, withCredentials nos permite usar las credenciales de jenkins, especifico el id de las credenciales de git para obtenerlas en la variable GH_TOK y ejecuto `jenkinsScripts/push.sh` pasandole las credenciales

```groovy
stage('Push_stages') {
    steps {
        script {
            withCredentials([usernameColonPassword(credentialsId: '79f36614-7aa8-4403-a7a6-cccd99088b2f', variable: 'GH_TOK')]) {
                sh 'sh jenkinsScripts/push.sh ${GH_TOK}'
            }
        }
    }
}
```

El script `push.sh` se encargará de crear el commit y subir los cambios, el parametro ${1} es el que contiene las credenciales de git, con un git remote set-url establezco las credenciales. Cuando hago commit pongo allow-empty para que permita un comit vacio (aunque no haya ningun cambio) y luego lo subo a la rama jenkins

```bash
#!/bin/bash

git remote set-url origin https://${1}@github.com/iferrer20/ghActions-Practica
git add .
git config --global user.name "iferrer20"
git config --global user.email "iferrer20@users.noreply.github.com"
git commit -m "jenkins_autocomit" --allow-empty
git push origin HEAD:jenkins
```

## Stage deploy_to_vercel (1,5)

El stage deploy_to_vercel se encargará de desplegar el proyecto en vercel si la salida de los tests de cypress y del lint son correctos, si no no se ejecutará vercel y el status_vercel será 'No executed'

```groovy
stage('Deploy_to_Vercel') {
    steps {
        script {
            withCredentials([
                string(credentialsId: 'mytoken', variable: 'TOKEN'),
                string(credentialsId: 'prjid', variable: 'PROJECT_ID'),
                string(credentialsId: 'orgid', variable: 'ORG_ID')
            ]) { 
                if (env.status_lint == "0" && env.status_tests == "0") {
                    env.status_vercel = sh(script: 'VERCEL_ORG_ID=$ORG_ID VERCEL_PROJECT_ID=$PROJECT_ID vercel --prod --scope iferrer20 --token=$TOKEN', returnStatus: true)
                } else {
                    env.status_vercel = 'No executed'
                }

           }
        }
    }
}
```

Para este stage se necesita instalar vercel en la máquina con `npm install -g vercel`  
Necesitaremos poner 3 tokens en las credenciales, el `token` `prjid` y `orgid`  
El token token es un token que tendremos que generar en settings->tokens  
El token prjid es nuestro user id lo podemos conseguir entrando a nuestro perfil  
El token orgid está en settings de nuestro proyecto de vercel
Como ultimo paso necesitaremos establecer esos tokens en el global credentials de Jenkins

![vercel tokens](https://raw.githubusercontent.com/iferrer20/ghActions-Practica/jenkins/readme_img/credentials.png)


## Stage notification (1,0)

En este stage utilizo 2 creedentials de tipo string, una es la api key de mailjet y la otra es el secret key de la cuenta de mailjet, luego dentro de withCredentials ejecuto el script `jenkinsScript/sendmail.sh` pasándole como ENV `MAILJET_API_KEY` y `MAILJET_SECRET_KEY` no necesito pasar nada mas ya que los params (correo, motivo, ejecutor) ya estan asignados en el ENV por lo que los podemos obtener sin problemas dentro del script.

```groovy
stage('Notificacion') {
    steps {
        script {
            withCredentials([
                string(credentialsId: 'mailjetapikey', variable: 'MAILJET_API_KEY'),
                string(credentialsId: 'mailjetsecretkey', variable: 'MAILJET_SECRET_KEY')
            ]) { 
                sh 'MAILJET_API_KEY=$MAILJET_API_KEY MAILJET_SECRET_KEY=$MAILJET_SECRET_KEY sh jenkinsScripts/sendmail.sh'
           }
        }
    }
}
```

El fichero `sendmail.sh` obtendra las variables y enviará el correo con las variables `${status_lint}` `${status_tests}` `${status_update}` `${status_vercel}`

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
        \"Email\": \"iferreriestacio@gmail.com\",
        \"Name\": \"iferrer20\"
      },
      \"To\": [
        {
          \"Email\": \"${correo}\",
          \"Name\": \"Ejecución por ${ejecutor}\"
        }
      ],
      \"Subject\": \"${motivo}\",
      \"TextPart\": \"Jenkins\",
      \"HTMLPart\": \"<p>Se ha realizado un push en la rama main que ha provocado la ejecución del workflow nombre_repositorio_workflow con los siguientes resultados:<br>Linter stage: ${status_lint}<br>Test stage: ${status_tests}<br>Update readme: ${status_update}<br>Deploy to vercel: ${status_vercel}</p>\",
      \"CustomID\": \"AppGettingStartedTest\"
    }
  ]
}
```



