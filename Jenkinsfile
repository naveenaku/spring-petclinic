pipeline {
  agent any

  environment {
    IMAGE_NAME = "naveenakula029/nodejs"
    IMAGE_TAG  = "latest"
    MAVEN_IMAGE = "maven:3.9.11-eclipse-temurin-25"
  }

  stages {
    stage('Checkout Code') {
      steps {
        git branch: 'main', url: 'https://github.com/naveenaku/spring-petclinic.git'
      }
    }

    stage('Build JAR') {
      steps {
        script {
          // Use the official Maven image (includes JDK 25). Run Maven inside the container.
          // Mount workspace .m2 into the container to cache dependencies and avoid permission issues.
          // Mount docker.sock so we can build images later on the same agent (optional but useful).
          docker.image(MAVEN_IMAGE).inside("-v ${env.WORKSPACE}/.m2:${env.HOME}/.m2 -v /var/run/docker.sock:/var/run/docker.sock") {
            sh 'echo "Container Java & Maven versions:"'
            sh 'java -version || true'
            sh 'mvn -v'
            // Use mvn from the image (safer than relying on repo's mvnw)
            sh 'mvn -B -DskipTests clean package'
          }
        }
      }
      post {
        success {
          archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          // Build docker image on the node (requires Docker daemon and permission)
          def img = docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
          // tag also (optional)
          sh "docker image ls ${IMAGE_NAME}:${IMAGE_TAG}"
        }
      }
    }

    stage('Login & Push to Docker Hub') {
      steps {
        script {
          // Uses Jenkins credential id 'Dockerhub-creds' (username/password)
          docker.withRegistry('', 'Dockerhub-creds') {
            // Push the previously built image
            docker.image("${IMAGE_NAME}:${IMAGE_TAG}").push()
          }
        }
      }
    }
  }

  post {
    success { echo "Pipeline succeeded" }
    failure { echo "Pipeline failed — check console" }
  }
}
