pipeline {
    agent any
    
    // Triggers for pipeline (works with webhooks and polling)
    triggers {
        // Polling as backup if webhook fails - checks every 5 minutes
        pollSCM('H/5 * * * *')
    }
    
    environment {
        GITHUB_TOKEN = credentials('${jenkins_github_credentials_id}')
        GITLAB_TOKEN = credentials('${jenkins_gitlab_credentials_id}')
        GITHUB_REPO = '${github_repo_full}'
        GITLAB_REPO = '${gitlab_project_path}'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Sync GitHub to GitLab') {
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    sh '''
                        python3 sync_repos.py code github-to-gitlab
                    '''
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}

