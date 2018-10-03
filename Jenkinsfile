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
        stage('user-java Tests Run') {
            when {
                changeset "apis/user-java/**"
            }
            agent {
                docker { image 'maven:3-alpine' }
            }
            steps {
                sh 'mvn -f apis/user-java/pom.xml test'
            }

        }
        stage('user-java build Image and Push') {
             when {
                 changeset "apis/user-java/**"
             }
             steps {
                  script {
                        def img = docker.build("openhacks3n5acr.azurecr.io/devopsoh/api-user-java:${env.BUILD_ID}", "apis/user-java")
                        img.push()
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

