pipeline {
    agent any
    
    triggers {
        cron('H * * * *')
    }
    
    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Syndrizzle/jenkins-stuff.git'
            }
        }
        
        stage('Check Disk Usage') {
            steps {
                script {
                    sh '''
                        chmod +x examples/disk_check.sh
                        ./examples/disk_check.sh
                    '''
                }
            }
        }
        
        stage('Process Management') {
            steps {
                script {
                    sh '''
                        chmod +x examples/process_monitor.sh
                        ./examples/process_monitor.sh
                    '''
                }
            }
        }
    }
    
    post {
        failure {
            emailext (
                subject: "CRITICAL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: """
                    FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':
                    Check console output at '${env.BUILD_URL}'
                    """,
                to: 'sahilnihalani0@gmail.com',
                from: 'jenkins@syndrizzle.me'
            )
        }
    }
}
