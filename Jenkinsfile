pipeline {
    agent {
        label 'linux'
    }

    tools {
        maven 'maven'
    }

    stages {

        stage('Maven Compile') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('Sonar') {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Build') {
            steps {
                sh 'mvn package'
                sh "ls -la"
                sh "ls -la target/"
            }
        }

        stage('Trivy File System Scan') {
            steps {
                sh '''
                    mkdir -p trivy-report
                    trivy fs --format table -o trivy-report/fs-report.txt .
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker builder prune -f || true
                    docker image prune -f || true
                    docker build -t hello-world:${BUILD_NUMBER} .
                '''
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh '''
                    mkdir -p /var/trivy-cache
                    trivy image \
                        --cache-dir /var/trivy-cache \
                        --scanners vuln \
                        --format table \
                        -o trivy-report/image-report.txt \
                        hello-world:${BUILD_NUMBER}
                '''
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-cred',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {

                        sh '''
                            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin

                            docker tag hello-world:${BUILD_NUMBER} $DOCKER_USER/hello-world:${BUILD_NUMBER}

                            docker push $DOCKER_USER/hello-world:${BUILD_NUMBER}
                        '''
                    }
                }
            }
        }

       stage('Deploy to EKS') {
    steps {
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'aws-cred'
        ]]) {

           sh '''
           sed -i "s|image:.*|image: dharimigariarjun/hello-web:${BUILD_NUMBER}|g" k8s/2-Deployment.yaml
           cat k8s/2-Deployment.yaml
           aws eks update-kubeconfig --region us-east-1 --name demo-cluster
           kubectl apply -f k8s
         '''
        }
    }
  }
    }
    post {

        always {
            archiveArtifacts artifacts: 'trivy-report/*', fingerprint: true
            cleanWs()
        }

        success {
            echo 'Pipeline SUCCESS - Deployment completed'
        }

        failure {
            echo 'Pipeline FAILED - check logs'
        }

        unstable {
            echo 'Pipeline UNSTABLE - issues detected'
        }
    }
}
