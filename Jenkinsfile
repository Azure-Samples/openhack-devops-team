node{
   stage('SCM Checkout'){
     git 'https://github.com/apraovjr/openhack-devops-team'
   }
  stage('Build') {
        withMaven(maven: 'Maven 3') {
            dir('apis/user-java') {
                sh 'mvn clean package'
            }
        }
    }
   stage('Email Notification'){
      mail bcc: '', body: '''Hi Welcome to jenkins email alerts
      Thanks
      Hari''', cc: '', from: '', replyTo: '', subject: 'Jenkins Job', to: 'aprao@microsoft.com'
   }
 }
