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
                    env.status_lint = sh(script: "npm run lint", returnStatus: true)
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    env.status_tests = sh(script: "npm run cypress", returnStatus: true)
                }
            }
        }
        stage('Update_Readme') {
            steps {
                sh "jenkinsScripts/readme.sh ${env.status_tests}"
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
                        sh 'VERCEL_ORG_ID=$ORG_ID VERCEL_PROJECT_ID=$PROJECT_ID vercel --prod --scope iferrer20 --token=$TOKEN'
                   }
                }
            }
        }
    }
}
