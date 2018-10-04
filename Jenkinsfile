pipeline {
    agent {
        node {
            label 'docker'
        }
    }

    stages {
        stage('poi tests run') {
            when {
                changeset "apis/poi/**"
            }
            agent {
                docker {
                    image 'microsoft/dotnet:2.1-sdk'
                    args '-v $HOME/.dotnet:/.dotnet -v $HOME/.nuget:/.nuget'
                }
            }
            steps {
                  sh 'cd apis/poi && dotnet test tests/UnitTests/UnitTests.csproj'
            }
        }
        stage('poi build docker image and push') {
            when {
                changeset "apis/poi/**"
            }
            steps {
                sh 'docker build -t openhacks3n5acr.azurecr.io/devopsoh/api-poi:$BUILD_ID apis/poi/web && docker push openhacks3n5acr.azurecr.io/devopsoh/api-poi:$BUILD_ID'
            }
        }
        stage('poi helm') {
             when {
                allOf {
                  changeset "apis/poi/**"
                  branch 'master'
                }
             }
             steps {
                  script {
                    sh 'helm upgrade api-poi $WORKSPACE/apis/poi/helm --set repository.image=openhacks3n5acr.azurecr.io/devopsoh/api-poi,repository.tag=$BUILD_ID,env.webServerBaseUri="http://akstraefikopenhacks3n5.westeurope.cloudapp.azure.com",ingress.rules.endpoint.host=akstraefikopenhacks3n5.westeurope.cloudapp.azure.com'
                  }
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
        stage('userprofile Tests run') {
            when {
                changeset "apis/userprofile/**"
            }
            agent {
                docker {
                    image 'node:8-alpine'
                }
            }
            steps {
                  sh 'cd apis/userprofile/ && npm install && npm run test'

            }
         }
         stage('userprofile SonarQube Analysis') {
             when {
                  changeset "apis/userprofile/**"
             }

             steps {
                 sh """docker run --rm \
                       --mount type=bind,source="${env.WORKSPACE}",target=/workspace \
                       -w "/workspace/apis/userprofile" \
                       newtmitch/sonar-scanner sonar-scanner \
                       -Dsonar.projectKey=Mimetis_openhack-devops-team-userprofile \
                       -Dsonar.organization=mimetis-github \
                       -Dsonar.projectName=userprofile \
                       -Dsonar.projectBaseDir=/workspace/apis/userprofile \
                       -Dsonar.sources= \
                       -Dsonar.host.url=https://sonarcloud.io \
                       -Dsonar.login=dd77b51aa204d65dab0dd6d5f0ef7fbb4e6c23cd \
                       -Dsonar.exclusions=**/node_modules/**/*,**/coverage/**/*,**/reports/**/* && sudo chown -R 1000:1000 "${env.WORKSPACE}/apis/userprofile" """

                 sh """sleep 10 && curl -s -u dd77b51aa204d65dab0dd6d5f0ef7fbb4e6c23cd: \$(cat ./apis/userprofile/.scannerwork/report-task.txt | grep ceTaskUrl | cut -d'=' -f2,3) | grep SUCCESS"""
             }
         }
         stage('userprofile build Image and Push') {
              when {
                  changeset "apis/userprofile/**"
              }
              steps {
                   script {
                         def img = docker.build("openhacks3n5acr.azurecr.io/devopsoh/api-user:${env.BUILD_ID}", "apis/userprofile")
                         img.push()
                   }
              }
         }
         stage('update userprofile application') {
             when {
                allOf {
                  changeset "apis/userprofile/**"
                  branch 'master'
                }
             }
             steps {
                  script {
                    sh '''#!/bin/bash
                          active=$(cat /home/jenkins/helm_values_stored/userprofile | grep active= | cut -d= -f2);
                          if [[ "$active" == "blue" ]]; then
                            echo "blue is active"
                            green=$BUILD_ID
                            blue=$(cat /home/jenkins/helm_values_stored/userprofile | grep blue= | cut -d= -f2);
                          else
                            echo "green is active"
                            blue=$BUILD_ID
                            green=$(cat /home/jenkins/helm_values_stored/userprofile | grep green= | cut -d= -f2);
                          fi
                      helm upgrade api-user $WORKSPACE/apis/userprofile/helm --set repository.image=openhacks3n5acr.azurecr.io/devopsoh/api-user,repository.tag=$BUILD_ID,repository.tag_green=$green,repository.tag_blue=$blue,active_version=$active,env.webServerBaseUri="http://akstraefikopenhacks3n5.westeurope.cloudapp.azure.com",ingress.rules.endpoint.host=akstraefikopenhacks3n5.westeurope.cloudapp.azure.com
                      cat << EOF > /home/jenkins/helm_values_stored/userprofile
active=$active
blue=$blue
green=$green
EOF
                    '''
                  }
             }
        }
    }

    post {

        failure {
            script {
                    properties([[$class: 'GithubProjectProperty',
                                projectUrlStr: 'https://github.com/Mimetis/openhack-devops-team']])
            }
            step([$class: 'GitHubIssueNotifier',
                  issueAppend: true,
                  issueLabel: '',
                  issueTitle: '$JOB_NAME $BUILD_DISPLAY_NAME failed'])
        }
    }
}
