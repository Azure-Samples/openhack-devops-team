pipeline {
    agent any

    stages {
        stage('poi') {
            steps {
                echo 'poi'
            }
        }
        stage('trips') {
            steps {
                echo 'trips'
            }
        }
        stage('user-java') {
            steps {
                echo 'user-java'
                node {
                    docker.build("user-java-test:latest", "apis/user-java")
                }
            }
        }
        stage('userprofile') {
             steps {
                 echo 'userprofile'
             }
         }
    }
}
