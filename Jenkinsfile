pipeline {
    agent any

    stages {
        stage ('1. Checkout code') {
            steps {
                checkout scm
            }
        }
        stage ('2. Docker image build') {
            steps {
                sh 'docker build -t sriramsrb/library5:latest .'
            }
        }
        stage ('3. Push docker image') {
            steps {
                withCredentials([string(credentialsId: 'docekrhub_user', variable: 'DOCKER_PWD')]) {
                    sh 'echo "$DOCKER_PWD" | docker login -u sriramsrb --password-stdin'
                    sh 'docker push sriramsrb/library5:latest'
                }
            }
        }
        stage ('4. deploy to kubernetes') {
            steps {
                sh 'kubectl apply -f deployment.yml'
                sh 'kubectl rollout restart deployment library5-deployment'
            }
        }
    }
}
