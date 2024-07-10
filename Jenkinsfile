pipeline {
 agent { node { label "maven-sonarqube-node" } }
 parameters   {
   string(name: 'aws_account', defaultValue: '322266404742', description: 'aws account hosting image registry')
   string(name: 'ecr_tag', defaultValue: '1.0.0', description: 'Choose the ecr tag version for the build')
       }
tools {
    maven "maven"
    }
    stages {
      stage('1. Git Checkout') {
        steps {
          git branch: 'dev', credentialsId: 'githubpriv', url: 'https://github.com/judithmagang/elitebook.git'
        }
      }
      stage('2. Build with maven') { 
        steps{
          sh "mvn clean package"
         }
       }
      stage('3. SonarQube analysis') {
      environment {SONAR_TOKEN = credentials('sonar-token-abook')}
      steps {
       script {
         def scannerHome = tool 'SonarQube-Scanner';
         withSonarQubeEnv("sonarqube-integration") {
         sh "${tool("SonarQube-Scanner")}/bin/sonar-scanner  \
           -Dsonar.projectKey=elitebook \
           -Dsonar.projectName='elitebook' \
           -Dsonar.host.url=http://18.116.72.231:9000 \
           -Dsonar.token=sonar-token-abook
           -Dsonar.sources=src/main/java/ \
           -Dsonar.java.binaries=target/classes"
          }
         }
       }
      }
      stage('4. Docker image build') {
         steps{
          sh "aws ecr get-login-password --region us-west-1 | sudo docker login --username AWS --password-stdin ${params.aws_account}.dkr.ecr.us-west-1.amazonaws.com"
          sh "sudo docker build -t elitebook ."
          sh "sudo docker tag elitebook:latest ${params.aws_account}.dkr.ecr.us-west-1.amazonaws.com/elitebook:${params.ecr_tag}"
          sh "sudo docker push ${params.aws_account}.dkr.ecr.us-west-1.amazonaws.com/elitebook:${params.ecr_tag}"
         }
       }
      stage('5. Application deployment in eks') {
        steps{
          kubeconfig(caCertificate: '',credentialsId: 'k8s-kubeconfig', serverUrl: '') {
          sh "kubectl apply -f manifest"
          }
         }
       }
       /*
      stage('6. Monitoring solution deployment in eks') {
        steps{
          kubeconfig(caCertificate: '',credentialsId: 'k8s-kubeconfig', serverUrl: '') {
          sh "kubectl apply -f monitoring"
          sh "chmod +x -R script"
          sh(""" script/createIRSA-AMPIngest.sh""")
          sh(""" script/createIRSA-AMPQuery.sh""")
          }
         }
       }
       
      stage ('7. Email Notification') {
         steps{
         mail bcc: 'fusisoft@gmail.com', body: '''Build is Over. Check the application using the URL below. 
         https//abook.shiawslab.com/elitebook-1.0
         Let me know if the changes look okay.
         Thanks,
         Dominion System Technologies,
         +1 (313) 413-1477''', cc: 'fusisoft@gmail.com', from: '', replyTo: '', subject: 'Application was Successfully Deployed!!', to: 'fusisoft@gmail.com'
      }
    }
 }
 */
}




