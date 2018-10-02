pipeline {
    agent {
        node {
            label 'docker'
        }
    }

    stages {
        stage('poi') {
            when {
                changeset "apis/poi/**"
            }
            steps {
                echo 'poi'
            }
        }
        stage('trips') {
            when {
                changeset "apis/trips/**"
            }
            steps {
                echo 'trips'
            }
        }
        stage('user-java') {
            when {
                changeset "apis/user-java/**"
            }
            steps {
                script {
                    def img = docker.build("openhacks3n5acr.azurecr.io/devopsoh/api-user-java:${env.BUILD_ID}", "apis/user-java")
                    img.push()
                }
            }
            post {
                success {
                    githubNotify status: "SUCCESS", description: "Success", credentialsId: "607c442b-27a1-4298-93b8-e74a46007bf9", account: "Mimetis", repo: "openhack-devops-team"
                }
                failure {
                    githubNotify status: "FAILURE", description: "Failure", credentialsId: "607c442b-27a1-4298-93b8-e74a46007bf9", account: "Mimetis", repo: "openhack-devops-team"
                }
            }
        }
        stage('userprofile') {
            when {
                changeset "apis/userprofile/**"
            }
            steps {
                echo 'userprofile'
            }
         }
    }
}
