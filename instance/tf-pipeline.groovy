pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/mayurmwagh/cdec-b52-53.git'
            }
        }

        stage('Deploy Infrastructure') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds']
                ]) {
                    sh '''
                    terraform init
                    terraform plan
                    terraform apply -auto-approve
                    '''
                }
            }
        }

    }
}