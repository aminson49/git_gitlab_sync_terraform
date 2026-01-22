pipeline {
    agent any
    
    // Triggers for pipeline (works with webhooks and polling)
    triggers {
        // Polling as backup if webhook fails - checks every 5 minutes
        pollSCM('H/5 * * * *')
    }
    
    environment {
        GITHUB_TOKEN = credentials('github-token')
        GITLAB_TOKEN = credentials('gitlab-token')
        GITHUB_REPO = 'aminson49/git_gitlab_sync_terraform'
        GITLAB_REPO = 'poc-group1603702/gitlab_github_sync_terraform'
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

