#!/usr/bin/env groovy
@Library('jenkins-shared-library')
def gv

pipeline {
    agent any
    tools {
        nodejs "my-nodejs"
    }
    environment {
        DOCKER_REPO_SERVER = '941523122081.dkr.ecr.us-west-1.amazonaws.com'
        DOCKER_REPO = '${DOCKER_REPO_SERVER}/react-nodejs'
    }
    stages {
        stage('increment version') {
            steps {
                script {
                    dir("my-app") {
                        sh 'npm version minor'
                        def packageJson = readJSON file: 'package.json'
                        def version = packageJson.version
                        env.IMAGE_NAME = "941523122081.dkr.ecr.us-west-1.amazonaws.com/react-nodejs:$version-$BUILD_NUMBER"
                    }
                }
            }
        }
        stage('Build and Push docker image') {
            steps {
                script {
                    echo "building then pushing image"
                    withCredentials([usernamePassword(credentialsId: 'ecr-credentials', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh "docker build -t ${IMAGE_NAME} ."
                        sh "echo $PASS | docker login -u $USER --password-stdin ${DOCKER_REPO_SERVER}"
                        sh "docker push ${IMAGE_NAME}"
                    }
                }
            }
        }
        stage("deploy") {
            environment {
                AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key_id')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins_aws_secret_access_key')
                APP_NAME = 'react-nodejs'
            }
            steps {
                script {
                    echo 'deploying docker image kubectl'
                    sh 'envsubst < kubernetes/deployment.yaml | kubectl apply -f -'
                    sh 'envsubst < kubernetes/service.yaml | kubectl apply -f -'

                }
            }
        }
        stage("commit version change") {
            steps {
                commitVersionChange("gitlab.com/tsmallwood/react-nodejs-example.git")
            }
        }
    }
}
