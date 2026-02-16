pipeline {
    agent any
    environment {
        ARM_SUBSCRIPTION_ID = credentials('azure_subscription_id')
        ARM_TENANT_ID       = credentials('azure_tenant_id')
        ARM_CLIENT_ID       = credentials('azure_client_id')
        ARM_CLIENT_SECRET   = credentials('azure_client_password')
    stages {
        stage('Azure Login') {
            steps {
                script {
                    sh '''
                        az login --service-principal \
                            --username $ARM_CLIENT_ID \
                            --password $ARM_CLIENT_SECRET \
                            --tenant $ARM_TENANT_ID
                        az account set --subscription $ARM_SUBSCRIPTION_ID
                    '''
                }
            }
        }
        stage('Checkout') {
            steps {
                script {
                    // Clone the repository
                    git branch: 'develop',
                        url: 'https://github.com/virajt71/Azure_VM_Image_Builder.git'
                }
            }
        }
        stage('Terraform - Image Builder') {
            steps {
                script {
                    sh '''
                        cd root
                        terraform init -reconfigure
                        terraform ${action} -auto-approve 
                    '''
                }
            }
        }
    }

    post {
        always {
            script {
                // Logout from Azure
                sh 'az logout || true'
            }
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed! Check logs for details.'
        }
    }
}
