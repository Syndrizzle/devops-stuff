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
        
        // IF YOUR GITHUB REPOSITORY IS PRIVATE, USE THIS SECTION TO CONFIGURE YOUR CHECKOUT STAGE WITH YOUR GIT CREDENTIALS. REFER TO THE DOCS ON HOW TO CONFIGURE THE CREDENTIALS.
        // stage('Git Checkout') {
        //     steps {
        //         // Using credentials to checkout private repository
        //         withCredentials([usernamePassword(credentialsId: 'github-access', 
        //                                        usernameVariable: 'GIT_USERNAME', 
        //                                        passwordVariable: 'GIT_PASSWORD')]) {
        //             sh '''
        //                 git config --global credential.helper cache
        //                 echo "https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com" > ~/.git-credentials
        //             '''
        //             git branch: 'main', 
        //                 url: 'https://github.com/Syndrizzle/jenkins-stuff.git',
        //                 credentialsId: 'github-access'
        //         }
        //     }
        // }

        
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
