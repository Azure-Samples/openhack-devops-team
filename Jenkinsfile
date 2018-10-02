pipeline {
    agent any

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
                    docker.withServer("tcp://10.0.0.4:4243") {
                        def img = docker.build("openhacks3n5acr.azurecr.io/devopsoh/api-user-java:1", "apis/user-java")
                        img.push()
                    }
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
