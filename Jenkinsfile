
node('java8') {
  stage('Configure') {
    env.PATH = "${tool 'maven-3.3.9'}/bin:${env.PATH}"
  }
  stage('SCM Checkout'){
     git 'https://github.com/apraovjr/openhack-devops-team'
  }
  stage('Build') {
    sh 'mvn -f /apis/user-java/pom.xml clean package'
  }
}
