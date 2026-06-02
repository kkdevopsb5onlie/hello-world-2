pipeline {
    agent {
        label 'linux'
    }

    tools {
        maven 'maven'
    }

    stages {

        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Package') {
            steps {
                sh 'mvn package'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('Sonar') {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Trivy File System Scan') {
            steps {
                sh 'trivy fs .'
            }
        }

        stage('Docker Build') {
            steps {
                sh "docker builder prune -af || true"
                sh "docker image prune -f || true"
                sh 'docker rmi hello-world:latest || true'
                sh 'docker build -t hello-world:latest .'
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh '''
                mkdir -p /opt/trivy-cache
                TMPDIR=/opt/trivy-cache trivy image \
                  --cache-dir /opt/trivy-cache \
                  --scanners vuln hello-world:latest
                '''
            }
        }
    }

    // ✅ POST ACTIONS (IMPORTANT)
    post {

        always {
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
