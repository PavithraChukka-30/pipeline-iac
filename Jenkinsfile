pipeline {
    agent any

    parameters {
        choice(name: 'ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Terraform action')
    }

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
        TF_IN_AUTOMATION   = 'true'
        TF_VAR_my_ip_cidr  = '183.82.106.91/32'
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh 'terraform init -input=false'
                }
            }
        }

        stage('Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Plan') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh 'terraform plan -input=false -out=tfplan'
                }
            }
        }

        stage('Approve') {
            when { expression { params.ACTION != 'plan' } }
            steps {
                input message: "Run terraform ${params.ACTION}?", ok: 'Yes, proceed'
            }
        }

        stage('Apply / Destroy') {
            when { expression { params.ACTION != 'plan' } }
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    script {
                        if (params.ACTION == 'apply') {
                            sh 'terraform apply -input=false tfplan'
                        } else {
                            sh 'terraform destroy -auto-approve -input=false'
                        }
                    }
                }
            }
        }
    }

    post {
        success { echo "Terraform ${params.ACTION} finished" }
        failure { echo 'Terraform pipeline failed' }
    }
}