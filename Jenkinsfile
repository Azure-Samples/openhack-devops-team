pipeline {
  agent any
  stages {
    stage('Build Docker Image') {
      steps {
        echo 'Building POI API ...'
        echo 'Fetching credentials...'
        withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'acr-credentials',
            usernameVariable: 'ACR_ID', passwordVariable: 'ACR_PASSWORD']]) {

            sh 'echo uname=$ACR_ID pwd=$ACR_PASSWORD'
        }
      }
    }
  }
}
