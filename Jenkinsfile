pipeline {
    agent any
    triggers {
        pollSCM('3 * * * *')
    }
    parameters {
        string(name: 'ejecutor', description: 'Ejecutor')
        string(name: 'motivo', description: 'Motivo')
        string(name: 'correo', description: 'Correo notificación')
    }
    stages {
        stage('Install') {
            steps {
                sh 'npm install'
            }
        }
        stage('Linter') {
            steps {
                script {
                    env.status_lint = sh(script: "npm run lint", returnStatus: true)
                }
            }
        }
        stage('Test') {
            steps {
                sh 'npm run dev &'
                script {
                    env.status_tests = sh(script: "npm run cypress", returnStatus: true)
                }
            }
        }
        stage('Update_Readme') {
            steps {
                script {
                    env.status_update = sh(script: "jenkinsScripts/readme.sh", returnStatus: true)
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
                        if (env.status_lint == "0" && env.status_tests == "0") {
                            env.status_vercel = sh(script: 'VERCEL_ORG_ID=$ORG_ID VERCEL_PROJECT_ID=$PROJECT_ID vercel --prod --scope iferrer20 --token=$TOKEN', returnStatus: true)
                        } else {
                            env.status_vercel = 'No executed'
                        }

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
                        sh 'EXECUTOR=$params.ejecutor TO_EMAIL=$params.correo SUBJECT=$params.motivo MAILJET_API_KEY=$MAILJET_API_KEY MAILJET_SECRET_KEY=$MAILJET_SECRET_KEY sh jenkinsScripts/sendmail.sh'
                   }
                }
            }
        }
    }
}
