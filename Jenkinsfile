pipeline {
    agent { node { label 'maven-sonarqube-node' } }
    
    parameters {
        string(name: 'aws_account', defaultValue: '851725403938', description: 'AWS account hosting image registry')
        string(name: 'ecr_tag', defaultValue: '1.0.0', description: 'Choose the ECR tag version for the build')
    }
    
    tools {
        maven 'maven'
    }
    
    stages {
        stage('1. Git Checkout') {
            steps {
                git branch: 'dev1', credentialsId: 'elitesgithub', url: 'https://github.com/elitessystems01/elitebook.git'
            }
        }
        
        stage('2. Build with Maven') { 
            steps {
                sh 'mvn clean package'
            }
        }
        
        stage('3. SonarQube analysis') {
            environment {
                SONAR_TOKEN = credentials('sonar-credentials')
            }
            steps {
                script {
                    def scannerHome = tool 'SonarQube-Scanner'
                    withSonarQubeEnv('sonarqube-integration') {
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=elitebook \
                            -Dsonar.projectName='elitebook' \
                            -Dsonar.host.url=http://3.85.226.149:9000 \
                            -Dsonar.token=$SONAR_TOKEN \
                            -Dsonar.sources=src/main/java/ \
                            -Dsonar.java.binaries=target/classes
                        """
                    }
                }
            }
        }
        
        stage('4. Docker image build') {
            steps {
                sh """
                    aws ecr get-login-password --region us-east-1 | sudo docker login --username AWS --password-stdin ${params.aws_account}.dkr.ecr.us-east-1.amazonaws.com
                    sudo docker build -t elitebook .
                    sudo docker tag elitebook:latest ${params.aws_account}.dkr.ecr.us-east-1.amazonaws.com/elitebook:${params.ecr_tag}
                    sudo docker push ${params.aws_account}.dkr.ecr.us-east-1.amazonaws.com/elitebook:${params.ecr_tag}
                """
            }
        }
        
        stage('5. Application deployment in EKS') {
            steps {
                kubeconfig(caCertificate: '', credentialsId: 'k8s-kubeconfig', serverUrl: '') {
                    sh 'kubectl apply -f manifest'
                }
            }
        }
        /*
        stage('6. Monitoring solution deployment in EKS') {
            steps {
                kubeconfig(caCertificate: '', credentialsId: 'k8s-kubeconfig', serverUrl: '') {
                    sh 'kubectl apply -f monitoring'
                    sh 'chmod +x -R script'
                    sh 'script/createIRSA-AMPIngest.sh'
                    sh 'script/createIRSA-AMPQuery.sh'
                }
            }
        }
        
        stage('7. Email Notification') {
            steps {
                mail bcc: 'fusisoft@gmail.com', body: '''
                    Build is Over. Check the application using the URL below. 
                    https://abook.shiawslab.com/elitebook-1.0
                    Let me know if the changes look okay.
                    Thanks,
                    Dominion System Technologies,
                    +1 (313) 413-1477
                ''', cc: 'fusisoft@gmail.com', from: '', replyTo: '', subject: 'Application was Successfully Deployed!!', to: 'fusisoft@gmail.com'
            }
        }
        */
    }
}




