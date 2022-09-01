pipeline {
    agent any
    environment {
        ANSIBLE_SERVER = "143.198.66.124"
    }
    stages {
        stage("copy files to ansible server") {
           steps {
            script {
                echo "copying all necessary files to ansible control node"
                sshagent(['ansible']) {
                    sh "scp -o StrictHostKeyChecking=no ansible/* root@${ANSIBLE_SERVER}:/root"

                    withCredentials([sshUserPrivateKey(credentialsId: 'ec2-server', keyFileVariable: 'keyfile', usernameVariable: 'user')]) {
                        sh 'scp $keyfile root@$ANSIBLE_SERVER:/root/ssh-key.pem'
                    }
                }
            }
           }
        }
        stage("execute ansible playbook") {
            steps {
                script {
                    echo "calling ansible playbook to config ec2 instances"
                    def remote = [:]
                    remote.name = "ansible-server"
                    remote.host = ANSIBLE_SERVER
                    remote.allowAnyHosts = true

                    withCredentials([sshUserPrivateKey(credentialsId: 'ansible', keyFileVariable: 'keyfile', usernameVariable: 'user')]) {
                         remote.user = user
                         remote.identityFile = keyfile
                         // sshScript remote: remote, script: "prepare-ansible-server.sh"
                         sshCommand remote: remote, command: "ansible-playbook my-playbook.yaml"
                    }

                }
            }
        }

    }
}