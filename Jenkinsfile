pipeline {

    agent any

    stages {
        stage('Building image') {
            steps{
                script {
                sh 'docker build "apis/user-java/" -t user-java:v4'
            }
        }
        }
        stage('Pushing image to ACR') {
            steps{
                    script {
                        withCredentials([[usernamePassword(credentialsId: 'ACR_JENKINS')]]){
                                sh 'docker login openhack58u7acr.azurecr.io'
                                sh 'docker tag user-java:$BUILD_NUMBER openhack58u7acr.azurecr.io/user-java:$BUILD_NUMBER'
                                sh 'docker push openhack58u7acr.azurecr.io/user-java:v4'
                                }
                        
                    }     
            }
        }
    }
      
    
  
}
