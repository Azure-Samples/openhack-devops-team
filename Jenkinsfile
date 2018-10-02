pipeline {
    agent any

    stages {
        stage('poi') {
            steps {
                echo 'poi'
            }
        }
        stage('trips') {
            steps {
                echo 'trips'
            }
        }
        stage('user-java') {
steps {
script {
docker.withServer("tcp://10.0.0.4:4243", "AzureDockerRegistry") {
                    def img = docker.build("openhacks3n5acr.azurecr.io/devopsoh/api-user-java:1", "apis/user-java")
                    img.push()
}
}
}
        }
        stage('userprofile') {
             steps {
                 echo 'userprofile'
             }
         }
    }
}
