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
        stage('trips Tests run') {
            when {
                changeset "apis/trips/**"
            }
            agent {
                docker {
                    image 'golang:1.11'
                    args '-v $HOME/.cache:/.cache'
                }
            }
            steps {
                  sh 'cd apis/trips/ && go mod vendor && go test ./test'

            }
        }
        stage('trips build Image and Push') {
             when {
                 changeset "apis/trips/**"
             }
             steps {
                  script {
                        docker.build("openhacks3n5acr.azurecr.io/devopsoh/api-trip:${env.BUILD_ID}", "apis/trips").push()

                  }
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

            post {
                always {
                    junit '**/target/*-reports/TEST-*.xml'
                    step([$class: 'JacocoPublisher',
                          execPattern: 'apis/user-java/target/*.exec',
                          classPattern: 'apis/user-java/target/classes',
                          sourcePattern: 'apis/user-java/src/main/java',
                          exclusionPattern: 'apis/user-java/src/test*'
                    ])

                }
             }

        }
//        stage('user-java SonarQube Analysis') {
//            when {
//                changeset "apis/user-java/**"
//            }
////            agent {
//                docker { image 'sonarqube' }
//            }
//            steps {
//                    sh 'mvn clean package sonar:sonar'
//             }
//        }
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
