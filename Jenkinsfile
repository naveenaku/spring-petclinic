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

    // Build inside Maven+Temurin JDK 25 image, but DO NOT mount host ~/.m2
    stage('Build JAR') {
      agent {
        docker {
          image 'maven:3.9-eclipse-temurin-25'
          // removed host $HOME/.m2 mount to avoid permission issues
          // if you have a secure shared m2 cache, an admin can set it up with correct ownership
          args '' 
        }
      }
      environment {
        // set local repo to workspace so no write attempt to /root/.m2 occurs
        MAVEN_OPTS = "-Dmaven.repo.local=${env.WORKSPACE}/.m2/repository"
      }
      steps {
        sh 'java -version'
        sh 'mvn -v'

        sh 'chmod +x mvnw'
        // the -Dmaven.repo.local (via MAVEN_OPTS above) ensures local repo is inside workspace
        sh './mvnw -B clean package -DskipTests'
      }
      // optional: stash the produced jar for later stages if needed
      post {
        success {
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
