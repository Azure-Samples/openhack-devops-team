pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                sh 'dotnet build "apis/poi" --configuration Release'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}
