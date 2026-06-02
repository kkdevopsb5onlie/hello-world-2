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
                    docker build -t hello-world:latest .
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
                        hello-world:latest
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

                            docker tag hello-world:latest $DOCKER_USER/hello-world:latest

                            docker push $DOCKER_USER/hello-world:latest
                        '''
                    }
                }
            }
        }
    }

    post {

        always {
            archiveArtifacts artifacts: 'trivy-report/*', fingerprint: true
            echo 'Cleaning workspace...'
            cleanWs()
        }

        success {
            echo 'Pipeline SUCCESS - Build completed'
        }

        failure {
            echo 'Pipeline FAILED - check logs'
        }

        unstable {
            echo 'Pipeline UNSTABLE - tests or scans failed'
        }
    }
}
