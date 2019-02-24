pipeline {
  agent any
  environment {
    ACR_CREDENTIALS = credentials('acr-credentials')
    WEB_IMAGE_NAME = ''
  }
  stages {         
    stage('Build POI Image') {
      steps {
        echo 'Building POI API Docker Image...'
         sh '''
           # Build new image and push to ACR.
           WEB_IMAGE_NAME="${ACR_LOGINSERVER}/devopsoh/api-poi:${BUILD_NUMBER}"
           docker build -t $WEB_IMAGE_NAME ./apis/poi/web/
         '''
      }
    }
    stage('Push POI Image') {
      steps {
        echo 'Pushing POI API Docker Image...'
        sh '''
          echo $WEB_IMAGE_NAME
          #docker login ${ACR_LOGINSERVER} -u ${ACR_CREDENTIALS:USR} -p ${ACR_CREDENTIALS:PSW}
          #docker push $WEB_IMAGE_NAME
        '''
      }
    }
  }
}
