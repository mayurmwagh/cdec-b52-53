pipeline {
    agent any

    parameters {
        string(
            name: 'TERRAFORM_STATE_BUCKET',
            defaultValue: 'terraform-state-bucket',
            description: 'S3 bucket name for Terraform state storage'
        )
        string(
            name: 'AWS_REGION',
            defaultValue: 'us-east-1',
            description: 'AWS region for deployment'
        )
    }

    environment {
        TERRAFORM_STATE_BUCKET = "${params.TERRAFORM_STATE_BUCKET}"
        AWS_REGION = "${params.AWS_REGION}"
    }

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
                    credentialsId: 'aws_creds']
                ]) {
                    sh '''
                    cd instance
                    
                    # Initialize Terraform with S3 backend
                    terraform init \
                      -backend-config="bucket=${TERRAFORM_STATE_BUCKET}" \
                      -backend-config="key=terraform/state" \
                      -backend-config="region=${AWS_REGION}" \
                      -backend-config="encrypt=true" \
                      -backend-config="dynamodb_table=terraform-locks"
                    
                    # Plan and apply
                    terraform plan
                    terraform apply -auto-approve
                    '''
                }
            }
        }

    }
}
