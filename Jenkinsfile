pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID=credentials('AWS_ACCOUNT_ID')
        AWS_DEFAULT_REGION="ap-southeast-1"
        IMAGE_REPO_NAME="to-do-app-grp1"
        IMAGE_TAG="${currentBuild.number}"
        REPOSITORY_URI = credentials('REPOSITORY_URI')
        EKS_CLUSTER_NAME=credentials('EKS_CLUSTER_NAME')
    }
   
    stages {
        
         stage('Connect to AWS account') {
            steps {
                script {
                sh """aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"""
                }
                 
            }
        }
        
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '', url: 'https://github.com/SelvaKumarN/to-do-app.git']]])     
            }
        }
        stage('Static code analysis') {
            steps {
                    sh('npm install')
                    sh('npm run lint > eslint.xml || echo "Lint failed- continuing with build"')
            }
            post {
                always {
                    archiveArtifacts artifacts: 'eslint.xml', onlyIfSuccessful: true
                }
            }
        }
        
  
    stage('Building docker image') {
      steps{
        script {
          dockerImage = docker.build "${IMAGE_REPO_NAME}:${IMAGE_TAG}"
        }
      }
    }
   
    stage('Pushing to ECR') {
     steps{  
         script {
                sh """docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:$IMAGE_TAG"""
                sh """docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:latest"""
                sh """docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${IMAGE_TAG}"""
                sh """docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:latest"""
         }
        }
      }
    stage('Deploy to EKS') {
        steps {
                  sh('aws eks update-kubeconfig --region ${AWS_DEFAULT_REGION}  --name ${EKS_CLUSTER_NAME}')
                  sh('kubectl apply -f todo-deployment.yml')
                  sh('kubectl apply -f todo-cluster-ip.yml')
                  sh('kubectl apply -f todo-lb.yml')
            }
      }
    }
}