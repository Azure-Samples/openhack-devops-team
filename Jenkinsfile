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
              echo uname=$ACR_ID pwd=$ACR_PASSWORD'
              # Build new image and push to ACR.
              WEB_IMAGE_NAME="${ACR_LOGINSERVER}/azure-vote-front:kube${BUILD_NUMBER}"
              docker build -t $WEB_IMAGE_NAME ./azure-vote
            '''
        }
        sh 'echo $ACR_ID'
      }
    }
  }
}
