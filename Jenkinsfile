
node{
   def server = Artifactory.newServer url: SERVER_URL, credentialsId: CREDENTIALS
   def rtMaven = Artifactory.newMavenBuild()
   def buildInfo
   
   stage('SCM Checkout'){
     git 'https://github.com/apraovjr/openhack-devops-team'
   }
}
