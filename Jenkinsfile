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
        git branch: 'main', url: 'https://github.com/naveenaku/spring-petclinic.git'
      }
    }

    // Use an image that includes BOTH Maven and Temurin JDK 25
    stage('Build JAR') {
      agent {
        docker {
          image 'maven:3.9-eclipse-temurin-25'   // Maven + JDK 25
          args '-v $HOME/.m2:/root/.m2'         // cache Maven repo between runs (optional)
        }
      }
      steps {
        // diagnostics (will succeed because this image includes mvn)
        sh 'java -version'
        sh 'mvn -v'

        // build using the wrapper (or 'mvn' directly)
        sh 'chmod +x mvnw'
        // prefer the wrapper to keep consistent Maven version, but 'mvn' is available too
        sh './mvnw -B clean package -DskipTests'
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
