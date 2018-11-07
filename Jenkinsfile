node{
   stage('SCM Checkout'){
     git 'hhttps://github.com/apraovjr/openhack-devops-team/tree/master/apis/user-java'
   }
   stage('Compile-Package'){
      // Get maven home path
      def mvnHome =  tool name: 'maven-3', type: 'maven'   
      sh "${mvnHome}/bin/mvn package"
   }
   stage('Email Notification'){
      mail bcc: '', body: '''Hi Welcome to jenkins email alerts
      Thanks
      Hari''', cc: '', from: '', replyTo: '', subject: 'Jenkins Job', to: 'aprao@microsoft.com'
   }
 }
