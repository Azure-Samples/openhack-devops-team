pipeline {
  agent any
  stages {
            withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'acr-credentials',
            usernameVariable: 'ACR_ID', passwordVariable: 'ACR_PASSWORD']]) {
    stage('Build Docker Image') {
      steps {
        echo 'Building POI API Docker Image...'
        echo 'Fetching credentials...'


            sh '''
              # Build new image and push to ACR.
              WEB_IMAGE_NAME="${ACR_LOGINSERVER}/devopsoh/api-poi:${BUILD_NUMBER}"
              docker build -t $WEB_IMAGE_NAME ./apis/poi/web/
            '''
        }
      }
    }
    stage('Push Docker Image') {
      steps {
        echo 'Pushing POI API Docker Image...'
        echo 'Fetching credentials...'           
      }
    }
  }
}
