pipeline {
    agent any
    triggers {
        pollSCM('3 * * * *')
    }
    parameters {
        text(name: 'ejecutor', description: 'Ejecutor')
        text(name: 'motivo', description: 'Motivo')
        text(name: 'correo', description: 'Correo notificación')
    }
    stages {
        stage('Linter') {
            steps {
                script {
                    env.status_lint = sh("npm run lint", returnStatus: true)
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    env.status_tests = sh("npm run cypress", returnStatus: true)
                }
            }
        }
        stage('Update_Readme') {
            steps {
                script {
                    env.status_update = sh("jenkinsScripts/readme.sh ${env.status_tests}", returnStatus: true)
                }

            }
        }
        stage('Push_stages') {
            steps {
                script {
                    withCredentials([usernameColonPassword(credentialsId: '79f36614-7aa8-4403-a7a6-cccd99088b2f', variable: 'GH_TOK')]) {
                        sh 'sh jenkinsScripts/push.sh ${GH_TOK}'
                    }
                }
            }
        }
        stage('Deploy_to_Vercel') {
            steps {
                script {
                    withCredentials([
                        string(credentialsId: 'mytoken', variable: 'TOKEN'),
                        string(credentialsId: 'prjid', variable: 'PROJECT_ID'),
                        string(credentialsId: 'orgid', variable: 'ORG_ID')
                    ]) { 
                        env.status_vercel = sh('VERCEL_ORG_ID=$ORG_ID VERCEL_PROJECT_ID=$PROJECT_ID vercel --prod --scope iferrer20 --token=$TOKEN', returnStatus: true)
                   }
                }
            }
        }

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
    }
}
