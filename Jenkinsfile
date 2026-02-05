pipeline {
    agent {
        label 'nodejs-docker'
    }

    environment {
        REGISTRY = '21120414/haquocbao.id.vn'
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_CREDENTIALS_ID = '2866c8c9-df5c-4e55-8190-7184500e646f'
        SCM_CREDENTIALS_ID = 'b93e0344-0588-4000-a1f2-5b9ae29383fb'
        GIT_OWNER = 'hoangtu47'
        GIT_REPO = 'haquocbao.id.vn'

    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build and Deploy') {
            when {
                anyOf {
                    changeset 'src/**'
                    changeset 'static/**'
                    changeset 'Dockerfile'
                    changeset 'Jenkinsfile'
                    changeset 'package.json'
                    changeset 'package-lock.json'
                    changeset 'svelte.config.js'
                    changeset 'vite.config.js'
                    changeset '.npmrc'
                    changeset '.dockerignore'
                    changeset '.gitignore'
                }
            }
            stages {
                stage('Install & Build') {
                    steps {
                        githubNotify description: 'Step running...', status: 'PENDING', context: 'Install & Build', credentialsId: SCM_CREDENTIALS_ID, account: GIT_OWNER, repo: GIT_REPO, sha: GIT_COMMIT
                        container('nodejs') {
                            sh 'apt-get update && apt-get install -y python3 make g++'
                            sh 'npm ci'
                            sh 'npm run build'
                        }
                    }
                    post {
                        success {
                            githubNotify description: 'Step passed', status: 'SUCCESS', context: 'Install & Build', credentialsId: SCM_CREDENTIALS_ID, account: GIT_OWNER, repo: GIT_REPO, sha: GIT_COMMIT
                        }
                        failure {
                            githubNotify description: 'Step failed', status: 'FAILURE', context: 'Install & Build', credentialsId: SCM_CREDENTIALS_ID, account: GIT_OWNER, repo: GIT_REPO, sha: GIT_COMMIT
                        }
                    }
                }

                stage('Docker Build') {
                    steps {
                        githubNotify description: 'Step running...', status: 'PENDING', context: 'Docker Build', credentialsId: SCM_CREDENTIALS_ID, account: GIT_OWNER, repo: GIT_REPO, sha: GIT_COMMIT
                        container('docker-cli') {
                            sh 'docker build -t $REGISTRY:$IMAGE_TAG -t $REGISTRY:latest .'
                        }
                    }
                    post {
                        success {
                            githubNotify description: 'Step passed', status: 'SUCCESS', context: 'Docker Build', credentialsId: SCM_CREDENTIALS_ID, account: GIT_OWNER, repo: GIT_REPO, sha: GIT_COMMIT
                        }
                        failure {
                            githubNotify description: 'Step failed', status: 'FAILURE', context: 'Docker Build', credentialsId: SCM_CREDENTIALS_ID, account: GIT_OWNER, repo: GIT_REPO, sha: GIT_COMMIT
                        }
                    }
                }

                stage('Docker Push') {
                    steps {
                        githubNotify description: 'Step running...', status: 'PENDING', context: 'Docker Push', credentialsId: SCM_CREDENTIALS_ID, account: GIT_OWNER, repo: GIT_REPO, sha: GIT_COMMIT
                        container('docker-cli') {
                            withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                                sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                                sh 'docker push $REGISTRY:$IMAGE_TAG'
                                sh 'docker push $REGISTRY:latest'
                            }
                        }
                    }
                    post {
                        success {
                            githubNotify description: 'Step passed', status: 'SUCCESS', context: 'Docker Push', credentialsId: SCM_CREDENTIALS_ID, account: GIT_OWNER, repo: GIT_REPO, sha: GIT_COMMIT
                        }
                        failure {
                            githubNotify description: 'Step failed', status: 'FAILURE', context: 'Docker Push', credentialsId: SCM_CREDENTIALS_ID, account: GIT_OWNER, repo: GIT_REPO, sha: GIT_COMMIT
                        }
                    }
                }

                stage('Update Manifest') {
                    steps {
                        githubNotify description: 'Step running...', status: 'PENDING', context: 'Update Manifest', credentialsId: SCM_CREDENTIALS_ID, account: GIT_OWNER, repo: GIT_REPO, sha: GIT_COMMIT
                        withCredentials([usernamePassword(credentialsId: SCM_CREDENTIALS_ID, passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                                sh '''
                                    git config user.email "haquocbao607@gmail.com"
                                    git config user.name "Jenkins CI"
                                    sed -i "s|image: 21120414/haquocbao.id.vn:.*|image: $REGISTRY:$IMAGE_TAG|g" k8s/deployment.yaml
                                    git add k8s/deployment.yaml
                                    git commit -m "Update image to $REGISTRY:$IMAGE_TAG [skip ci]"
                                    
                                    # Handle remote URL setup for push if using http/https credentials
                                    git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/hoangtu47/haquocbao.id.vn.git HEAD:main
                                '''
                            }
                        }
                    post {
                        success {
                            githubNotify description: 'Step passed', status: 'SUCCESS', context: 'Update Manifest', credentialsId: SCM_CREDENTIALS_ID, account: GIT_OWNER, repo: GIT_REPO, sha: GIT_COMMIT
                        }
                        failure {
                            githubNotify description: 'Step failed', status: 'FAILURE', context: 'Update Manifest', credentialsId: SCM_CREDENTIALS_ID, account: GIT_OWNER, repo: GIT_REPO, sha: GIT_COMMIT
                        }
                    }
                }
            }
        }
    }
}
