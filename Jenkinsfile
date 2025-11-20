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

    // Run the build inside a JDK 25 container so Maven Enforcer sees Java 25
    stage('Build JAR') {
      // use a Temurin JDK 25 image for this stage
      agent {
        docker {
          image 'eclipse-temurin:25-jdk'
          // cache Maven repository between runs (optional)
          args '-v $HOME/.m2:/root/.m2'
        }
      }
      steps {
        // diagnostics (useful when debugging CI)
        sh 'java -version'
        sh 'mvn -v'

        // ensure wrapper is executable and build
        sh 'chmod +x mvnw'
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
