pipeline {

    agent any

  stages {
    stage('Building image') {
      steps{
        script {
          docker.build "apis/user-java/"
      }
    }
  }
}