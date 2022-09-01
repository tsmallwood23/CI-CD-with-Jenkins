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
            steps {
                script {
                    echo 'deploying docker image kubectl'
                    withKubeConfig([credentialsId: 'lke-credentials', serverUrl: 'https://e73c775e-7435-4569-a439-4aec343ad057.us-west-1.linodelke.net']) {
                        sh 'kubectl create deployment nginx-deployment --image=nginx'
                    }

                }
            }
        }
    }
}
