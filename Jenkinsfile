pipeline {
  agent any
  stages {
    stage('Build Docker Image') {
      steps {
        echo 'Building POI API ...'
        echo 'Fetching credentials...'
        withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'acr-credentials',
            usernameVariable: 'ACR_ID', passwordVariable: 'ACR_PASSWORD']]) {

            sh '''
              # Build new image and push to ACR.
              WEB_IMAGE_NAME="${ACR_LOGINSERVER}/devopsoh/api-poi:${BUILD_NUMBER}"
              docker build -t $WEB_IMAGE_NAME -f ./apis/poi/web/Dockerfile
            '''
        }
        sh 'echo $ACR_ID'
      }
    }
  }
}
