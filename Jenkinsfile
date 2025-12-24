pipeline {
    // agent any
    agent {
        node {
            label 'Agent-1'
        }
    }
    stages {
        stage('Build') {
            steps {
                script {  
                    sh """ 
                    echo "Building"
                    echo ${BUILD_ID}
                    echo ${BUILD_NUMBER}
                    echo ${BUILD_TAG}
                    echo ${JOB_NAME}
                    """ 
                }   
            }
        }
        stage('Test') {
            steps {
                echo "Testing"
            }
        }
        stage('Deploy') {
            steps {
                echo "Deploying"
            }
        }
    }
    post{
        always{
            echo 'I will always say Hello again!'
            cleanWs()
        }
        success {
            echo 'I will run if success'
        }
        failure {
            echo 'I will run if failures'
        }
    }
}