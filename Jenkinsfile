pipeline {
    agent {
        label 'linux'
    }

    tools {
        maven 'maven'
    }

    stages {

        stage('Mavan compile') {
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
                   trivy fs --format table  --output trivy-report/fs-report.txt .
                 '''
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
                mkdir -p trivy-cache
                mkdir -p trivy-report
        
                TMPDIR=trivy-cache trivy image \
                  --cache-dir trivy-cache \
                  --scanners vuln \
                  --format table \
                  --output trivy-report/image-report.txt \
                  hello-world:latest
            '''
            }
        }
    }

    // ✅ POST ACTIONS (IMPORTANT)
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
