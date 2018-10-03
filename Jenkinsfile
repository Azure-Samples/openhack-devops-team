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
        stage('user-java SonarQube Analysis') {
            when {
                 changeset "apis/user-java/**"
            }

            steps {
                sh """docker run -t -d -u 1000:1000 --rm \
                      --mount type=bind,source="${env.WORKSPACE}",target=/workspace \
                      -w "/workspace/apis/user-java" \
                      newtmitch/sonar-scanner sonar-scanner \
                      -Dsonar.projectKey=Mimetis_openhack-devops-team-use-user-java \
                      -Dsonar.organization=mimetis-github \
                      -Dsonar.projectName=user-java \
                      -Dsonar.projectBaseDir=/workspace/apis/user-java \
                      -Dsonar.sources= \
                      -Dsonar.java.binaries=/workspace/apis/user-java/target/classes \
                      -Dsonar.host.url=https://sonarcloud.io \
                      -Dsonar.login=dd77b51aa204d65dab0dd6d5f0ef7fbb4e6c23cd \
                      -Dsonar.exclusions=**/node_modules/**/*,**/coverage/**/*,**/reports/**/* && chown -R 1000:1000 /workspace/apis/user-java """

                sh """sleep 10 && curl -s -u dd77b51aa204d65dab0dd6d5f0ef7fbb4e6c23cd: \$(cat ./apis/user-java/.scannerwork/report-task.txt | grep ceTaskUrl | cut -d'=' -f2,3) | grep SUCCESS"""
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

