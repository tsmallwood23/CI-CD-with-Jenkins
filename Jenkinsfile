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
        stage('provision-server') {
            // provisions the tf server
            environment {
                AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key_id')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins_aws_secret_access_key')
                TF_VAR_env_prefix = 'test'
            }
            steps {
                script {
                    dir('terraform') {
                        sh "terraform init"
                        sh "terraform apply --auto-approve"
                        EC2_PUBLIC_IP = sh(
                            script: "terraform output ec2_public_ip",
                            returnStdout: true
                        ).trim()
                    }
                }
            }
        }
        stage("deploy") {
            steps {
                script {
                    echo "waiting for ec2 to init"
                    sleep(time: 90, unit: "SECONDS")
                    echo "${EC2_PUBLIC_IP}"

                    def ec2Instance = "ec2-user@${EC2_PUBLIC_IP}"
                    def shellCMD = "bash ./server-cmds.sh ${IMAGE_NAME}"

                    sshagent(['server-ssh-key']) {
                        sh "scp -o StrictHostKeyChecking=no server-cmds.sh ec2-user@${EC2_PUBLIC_IP}:/home/ec2-user"
                        sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ec2-user@${EC2_PUBLIC_IP}:/home/ec2-user"
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@${EC2_PUBLIC_IP} ${shellCMD}"
                    }
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
