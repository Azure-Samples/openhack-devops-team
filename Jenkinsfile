pipeline {

    agent any

  stages {
    stage('Building image') {
      steps{
        script {
          sh 'docker build "apis/user-java/" -t user-java:v3'
      }
    }
  }
      
      
  stage('Pushing image to ACR') {
      steps{
        script {
            sh 'docker tag user-java:v3 openhack58u7acr.azurecr.io/user-java:v3'
            sh 'docker push openhack58u7acr.azurecr.io/user-java:v3'
            
      }
    }
  }

}
}
