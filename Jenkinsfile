pipeline {

    agent any

  stages {
    stage('Building image') {
      steps{
        script {
          sh 'docker build -f "apis/user-java/" -t user-java:v1 .'
      }
    }
  }
}
}
