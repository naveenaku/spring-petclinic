pipeline {
  agent any

  environment {
    IMAGE_NAME = "naveenakula029/nodejs"
    IMAGE_TAG  = "latest"
  }

  stages {
    stage('Checkout Code') {
      steps {
        // public repo: HTTPS is simplest
        git branch: 'master', url: 'https://github.com/naveenaku/spring-petclinic.git'
      }
    }

    stage('Build JAR') {
       steps {
            sh 'chmod +x mvnw'
            sh './mvnw clean package -DskipTests'
        }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
          echo "Building Docker image ${IMAGE_NAME}:${IMAGE_TAG}"
          docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
        '''
      }
    }

    stage('Login & Push to Docker Hub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'Dockerhub-creds', usernameVariable: 'DOCKERHUB_USR', passwordVariable: 'DOCKERHUB_PSW')]) {
          sh '''
            echo "$DOCKERHUB_PSW" | docker login -u "$DOCKERHUB_USR" --password-stdin
            docker push ${IMAGE_NAME}:${IMAGE_TAG}
            docker logout || true
          '''
        }
      }
    }
  }

  post {
    success { echo "Pipeline succeeded" }
    failure { echo "Pipeline failed — check console" }
  }
}
