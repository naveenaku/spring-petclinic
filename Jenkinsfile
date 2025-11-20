pipeline {
  agent any

  environment {
    IMAGE_NAME = "naveenakula029/nodejs"
    IMAGE_TAG  = "latest"
  }

  stages {
    stage('Checkout Code') {
      steps {
        git branch: 'main', url: 'https://github.com/naveenaku/spring-petclinic.git'
      }
    }

    stage('Build JAR') {
      agent {
        docker {
          image 'maven:3.9-eclipse-temurin-25'
          // don't mount host ~/.m2 to avoid permission problems
          args ''
        }
      }

      // set MAVEN_OPTS so Maven uses a repo inside the workspace
      environment {
        MAVEN_OPTS = "-Dmaven.repo.local=${WORKSPACE}/.m2/repository"
      }

      steps {
        // debug output (optional but useful)
        sh 'echo "WORKSPACE=${WORKSPACE}  HOME=${HOME}" || true'
        sh 'java -version'
        sh 'mvn -v'

        // run the wrapper but force HOME to the workspace so it won't try to create ///.m2
        sh 'chmod +x mvnw'
        sh 'HOME=${WORKSPACE} ./mvnw -B clean package -DskipTests'
      }

      post {
        success {
          // keep the JAR as a build artifact
          archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
        }
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
