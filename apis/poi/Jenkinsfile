pipeline {
  agent any
  environment {
    ACR_CREDENTIALS = credentials('acr-credentials')
    WEB_IMAGE_NAME = "${ACR_LOGINSERVER}/devopsoh/api-poi:${BUILD_NUMBER}"
  }
  stages {         
    stage('Build POI Image') {
      steps {
        echo 'Building POI API Docker Image...'
        echo "${WEB_IMAGE_NAME}"
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
          docker login ${ACR_LOGINSERVER} -u ${ACR_CREDENTIALS_USR} -p ${ACR_CREDENTIALS_PSW}
          docker push $WEB_IMAGE_NAME
        '''
      }
    }
  }
}
