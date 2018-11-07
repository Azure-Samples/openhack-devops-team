
node{
   def server = Artifactory.newServer url: SERVER_URL, credentialsId: CREDENTIALS
   def rtMaven = Artifactory.newMavenBuild()
   def buildInfo
   
   stage('SCM Checkout'){
     git 'https://github.com/apraovjr/openhack-devops-team'
   }
   stage ('Artifactory configuration') {
        rtMaven.tool = MAVEN_TOOL // Tool name from Jenkins configuration
        rtMaven.deployer releaseRepo: 'libs-release-local', snapshotRepo: 'libs-snapshot-local', server: server
        rtMaven.resolver releaseRepo: 'libs-release', snapshotRepo: 'libs-snapshot', server: server
        buildInfo = Artifactory.newBuildInfo()
   }
   stage('Compile-Package'){
      // Get maven home path
      rtMaven.run pom: 'apis/user-java/pom.xml', goals: 'clean install'
   }
   stage ('Publish build info') {
        server.publishBuildInfo buildInfo
   }
}
