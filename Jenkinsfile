#!/usr/bin/env groovy
@Library('jenkins-shared-library')
def gv

pipeline {
    agent any
    tools {
        nodejs "my-nodejs"
    }
    stages {
        stage('increment version') {
            steps {
                script {
                    dir("my-app") {
                        sh 'npm version minor'
                        def packageJson = readJSON file: 'package.json'
                        def version = packageJson.version
                        env.IMAGE_NAME = "tsmallwood23/my-repo:njse-$version-$BUILD_NUMBER"
                    }
                }
            }
        }
        stage('Build and Push docker image') {
            steps {
                buildImage("${IMAGE_NAME}")
                dockerLogin()
                dockerPush("${IMAGE_NAME}")
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
        //stage("commit version change") {
            //steps {
                //commitVersionChange("gitlab.com/tsmallwood/react-nodejs-example.git")
            //}
        //}
    }
}
