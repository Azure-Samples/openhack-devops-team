node{
   stage('SCM Checkout'){
     git 'https://github.com/apraovjr/openhack-devops-team'
   }
   stage('Compile-Package'){
      // Get maven home path
      def mvnHome =  tool name: '', type: 'maven'   
      sh "${mvnHome}/bin/mvn -f apis/user-java/pom.xml clean install"
   }
   stage('Email Notification'){
      mail bcc: '', body: '''Hi Welcome to jenkins email alerts
      Thanks
      Hari''', cc: '', from: '', replyTo: '', subject: 'Jenkins Job', to: 'aprao@microsoft.com'
   }
 }
