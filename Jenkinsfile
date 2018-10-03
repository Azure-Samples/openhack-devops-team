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
                echo 'build'
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
                        sh 'docker build -t openhacks3n5acr.azurecr.io/devopsoh/api-trip:$BUILD_ID apis/trips && docker push openhacks3n5acr.azurecr.io/devopsoh/api-trip:$BUILD_ID'

             }
        }
        stage('update helm application') {
             when {
                allOf {
                  changeset "apis/trips/**"
                  branch 'master'
                }
             }
             steps {
                  script {
                    sh 'helm upgrade api-trip $WORKSPACE/apis/trips/helm --set repository.image=openhacks3n5acr.azurecr.io/devopsoh/api-trip,repository.tag=$BUILD_ID,env.webServerBaseUri="http://akstraefikopenhacks3n5.westeurope.cloudapp.azure.com",ingress.rules.endpoint.host=akstraefikopenhacks3n5.westeurope.cloudapp.azure.com'
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
                    script {
                            properties([[$class: 'GithubProjectProperty',
                                        projectUrlStr: 'https://github.com/Mimetis/openhack-devops-team']])
                    }

                    junit '**/target/*-reports/TEST-*.xml'
                    step([$class: 'JacocoPublisher',
                          execPattern: 'apis/user-java/target/*.exec',
                          classPattern: 'apis/user-java/target/classes',
                          sourcePattern: 'apis/user-java/src/main/java',
                          exclusionPattern: 'apis/user-java/src/test*'
                    ])
                    step([$class: 'GitHubIssueNotifier',
                          issueAppend: true,
                          issueLabel: '',
                          issueTitle: '$JOB_NAME $BUILD_DISPLAY_NAME failed'])

                }
             }

        }
        stage('user-java SonarQube Analysis') {
            when {
                 changeset "apis/user-java/**"
            }

            steps {
                sh """docker run --rm \
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
                      -Dsonar.exclusions=**/node_modules/**/*,**/coverage/**/*,**/reports/**/* && sudo chown -R 1000:1000 "${env.WORKSPACE}/apis/user-java" """

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
        stage('update helm user-java') {
             when {
                allOf {
                  changeset "apis/user-java/**"
                  branch 'master'
                }
             }
             steps {
                  script {
                    sh 'helm upgrade api-user-java $WORKSPACE/apis/user-java/helm --set repository.image=openhacks3n5acr.azurecr.io/devopsoh/api-user-java,repository.tag=$BUILD_ID,env.webServerBaseUri="http://akstraefikopenhacks3n5.westeurope.cloudapp.azure.com",ingress.rules.endpoint.host=akstraefikopenhacks3n5.westeurope.cloudapp.azure.com'
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
