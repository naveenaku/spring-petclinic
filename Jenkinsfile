pipeline {
  agent any

  environment {
    IMAGE_NAME   = "naveenakula029/nodejs"
    IMAGE_TAG    = "latest"
    MAVEN_IMAGE  = "maven:3.9.11-eclipse-temurin-25" // Maven + Temurin JDK 25
    MVN_LOCAL_REPO = "${env.WORKSPACE}/.m2/repository"
  }

  stages {
    stage('Checkout Code') {
      steps {
        git branch: 'main', url: 'https://github.com/naveenaku/spring-petclinic.git'
      }
    }

    stage('Prepare local m2') {
      steps {
        // Ensure workspace .m2 exists and is writable by the container user
        sh '''
          mkdir -p "${WORKSPACE}/.m2"
          chmod -R 0777 "${WORKSPACE}/.m2" || true
        '''
      }
    }

    stage('Build JAR using Maven (JDK 25 container)') {
      steps {
        script {
          // Run Maven inside the selected Maven image which contains JDK 25.
          // Note: using env.WORKSPACE to avoid Groovy interpolation issues.
          docker.image(env.MAVEN_IMAGE).inside(
            // mount workspace local repo into container's root .m2
            // do NOT mount /var/run/docker.sock here unless you intentionally need docker inside container
            "-v ${env.WORKSPACE}/.m2:/root/.m2 -e HOME=/root -u root"
          ) {
            // Show which user and java/maven versions inside the container for debugging
            sh '''
              echo "=== inside build container ==="
              whoami || true
              id || true
              java -version || true
              mvn -v || true
            '''

            // Use a workspace-local maven repo explicitly to be safe
            sh '''
              mvn -B -DskipTests -Dmaven.repo.local="${WORKSPACE}/.m2/repository" clean package
            '''
          } // end inside
        } // end script
      } // end steps

      post {
        success {
          archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
        }
      }
    } // end Build stage

    stage('Build Docker Image') {
      steps {
        // This runs on the agent (not inside the maven container).
        sh '''
          docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
        '''
      }
    }

    stage('Login & Push to Docker Hub') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'Dockerhub-creds',
          usernameVariable: 'DOCKERHUB_USR',
          passwordVariable: 'DOCKERHUB_PSW'
        )]) {
          sh '''
            echo "$DOCKERHUB_PSW" | docker login -u "$DOCKERHUB_USR" --password-stdin
            docker push ${IMAGE_NAME}:${IMAGE_TAG}
            docker logout
          '''
        }
      }
    }
  } // end stages

  post {
    success {
      echo "Pipeline succeeded 🎉"
    }
    failure {
      echo "Pipeline failed — check console ❌"
    }
  }
}
