pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-1"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/mayurmwagh/cdec-b52-53.git'
            }
        }

        stage('Terraform Init') {
            steps {
                    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws_creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                
                    
                    sh '''
                        export AWS_DEFAULT_REGION=$AWS_REGION
                        terraform init
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws_creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {

                    sh '''
                        export AWS_DEFAULT_REGION=$AWS_REGION
                        terraform plan -out=tfplan
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws_creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
        
                    sh '''
                        export AWS_DEFAULT_REGION=$AWS_REGION
                        terraform apply -auto-approve tfplan
                    '''
                }
            }
        }
    }
}