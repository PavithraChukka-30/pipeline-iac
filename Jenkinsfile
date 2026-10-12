pipeline {
    agent any

    parameters {
        choice(name: 'ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Terraform action')
    }

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
        TF_IN_AUTOMATION   = 'true'
        TF_VAR_my_ip_cidr  = '183.82.106.91/32'
        APP_NAME           = 'myapp'
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

        stage('Terraform Validate') {
            steps { sh 'terraform validate' }
        }

        stage('Terraform Plan') {
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

        stage('Terraform Apply / Destroy') {
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

        stage('App Build') {
            when { expression { params.ACTION != 'destroy' } }
            steps {
                dir('app') {
                    sh 'mkdir -p build && echo "${APP_NAME} v1.${BUILD_NUMBER}" > build/app.txt'
                }
            }
        }

        stage('App Test') {
            when { expression { params.ACTION != 'destroy' } }
            steps {
                dir('app') {
                    sh 'test -f build/app.txt && echo "Test passed"'
                }
            }
        }

        stage('App Package') {
            when { expression { params.ACTION != 'destroy' } }
            steps {
                dir('app') {
                    sh 'tar czf ${APP_NAME}-${BUILD_NUMBER}.tar.gz build/'
                    archiveArtifacts artifacts: '*.tar.gz', fingerprint: true
                }
            }
        }

        stage('App Deploy') {
            when { expression { params.ACTION != 'destroy' } }
            steps {
                dir('app') {
                    sh 'mkdir -p /var/jenkins_home/deploy && cp ${APP_NAME}-${BUILD_NUMBER}.tar.gz /var/jenkins_home/deploy/'
                }
            }
        }
    }

    post {
        success { echo "Pipeline finished (ACTION=${params.ACTION})" }
        failure { echo 'Pipeline failed' }
    }
}