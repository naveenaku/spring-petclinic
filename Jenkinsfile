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

    stage('Build JAR using Maven') {
      steps {
        script {
          // Ensure workspace .m2 exists and is writable
          sh "mkdir -p ${WORKSPACE}/.m2 && chmod -R 777 ${WORKSPACE}/.m2 || true"

          // Run Maven inside the official Maven image.
          // Key points:
          // - Mount workspace .m2 into container's /root/.m2 (Maven default)
          // - Export HOME=/root inside the container to avoid Maven resolving HOME to '/'
          // - Run mvn as root (-u root) to avoid UID mismatch permission issues
          docker.image(MAVEN_IMAGE).inside(
            // -v mount, set HOME env, run as root so mvn can write to /root/.m2
            "-v ${WORKSPACE}/.m2:/root/.m2 -v /var/run/docker.sock:/var/run/docker.sock -e HOME=/root -u root"
          ) {
            // debug output
            sh 'echo "Inside container: whoami=$(whoami) HOME=$HOME"; id; ls -la /root || true'
            sh 'java -version || true'
            sh 'mvn -v'

            // Run mvn and explicitly set maven.repo.local as a fallback.
            // This ensures Maven will use the workspace-local repo no matter what HOME is.
            sh 'mvn -B -DskipTests -Dmaven.repo.local=${WORKSPACE}/.m2/repository clean package'
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
        sh """
          docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
        """
      }
    }

    stage('Login & Push to Docker Hub') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'Dockerhub-creds',
          usernameVariable: 'DOCKERHUB_USR',
          passwordVariable: 'DOCKERHUB_PSW'
        )]) {
          sh """
            echo "$DOCKERHUB_PSW" | docker login -u "$DOCKERHUB_USR" --password-stdin
            docker push ${IMAGE_NAME}:${IMAGE_TAG}
            docker logout
          """
        }
      }
    }
  }

  post {
    success {
      echo "Pipeline succeeded 🎉"
    }
    failure {
      echo "Pipeline failed — check console ❌"
    }
  }
}
