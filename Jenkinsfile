pipeline {

    agent any

  stages {
    stage('Building image') {
      steps{
        script {
          sh 'docker build "apis/user-java/"'
      }
    }
  }
}
}