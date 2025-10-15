pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '15'))
  }

  environment {
    // Registry details
    REGISTRY        = 'ghcr.io'
    IMAGE_NAMESPACE = 'adedokuntoluwanimi'

    // Generate safe tag from commit SHA
    COMMIT_SHA      = "${env.GIT_COMMIT?.take(7) ?: 'latest'}"
    IMAGE_TAG       = "${COMMIT_SHA}"

    BACKEND_IMAGE   = "${REGISTRY}/${IMAGE_NAMESPACE}/statuspulse-backend:${IMAGE_TAG}"
    FRONTEND_IMAGE  = "${REGISTRY}/${IMAGE_NAMESPACE}/statuspulse-frontend:${IMAGE_TAG}"

    // EC2 deploy info
    DEPLOY_USER     = 'ubuntu'
    DEPLOY_HOST     = '44.220.159.66'
    DEPLOY_PATH     = '/home/ubuntu/statuspulse'
  }

  stages {

    stage('Checkout') {
      steps {
        deleteDir()
        checkout scm
      }
    }

    stage('Login to GHCR') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'ghcr-token',
          usernameVariable: 'GH_USER',
          passwordVariable: 'GH_TOKEN'
        )]) {
          sh '''
            set -e
            echo "$GH_TOKEN" | docker login ghcr.io -u "$GH_USER" --password-stdin
          '''
        }
      }
    }

    stage('Build Backend Image') {
      steps {
        sh '''
          set -e
          echo "Building backend image..."
          docker build --pull --progress=plain -t "$BACKEND_IMAGE" ./backend
        '''
      }
    }

    stage('Build Frontend Image') {
      steps {
        sh '''
          set -e
          echo "Building frontend image..."
          docker build --pull --progress=plain -t "$FRONTEND_IMAGE" ./frontend
        '''
      }
    }

    stage('Push Images') {
      parallel {
        stage('Push Backend') {
          steps {
            sh '''
              set -e
              echo "Pushing backend image to GHCR..."
              docker push "$BACKEND_IMAGE"
            '''
          }
        }

        stage('Push Frontend') {
          steps {
            sh '''
              set -e
              echo "Pushing frontend image to GHCR..."
              docker push "$FRONTEND_IMAGE"
            '''
          }
        }
      }
    }

    stage('Deploy to EC2') {
      steps {
        sshagent(credentials: ['statuspulse-ssh-key']) {
          sh '''
            set -e

            echo "Deploying to EC2..."
            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_HOST} "mkdir -p ${DEPLOY_PATH}"

            scp -o StrictHostKeyChecking=no docker-compose.app.yml ${DEPLOY_USER}@${DEPLOY_HOST}:${DEPLOY_PATH}/docker-compose.yml

            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_HOST} bash -lc '
              set -e
              cd ${DEPLOY_PATH}
              echo REGISTRY=${REGISTRY} > .env
              echo IMAGE_NAMESPACE=${IMAGE_NAMESPACE} >> .env
              echo IMAGE_TAG=${IMAGE_TAG} >> .env

              echo "Pulling latest images..."
              docker compose --env-file .env pull

              echo "Starting containers..."
              docker compose --env-file .env up -d --remove-orphans

              echo "Cleaning unused Docker data..."
              docker system prune -af --volumes || true
            '
          '''
        }
      }
    }
  }

  post {
    always {
      sh 'docker logout ghcr.io || true'
      cleanWs()
    }

    success {
      echo "✅ Deployment completed successfully with tag ${IMAGE_TAG}"
    }

    failure {
      echo "❌ Pipeline failed. Check the Jenkins console logs for details."
    }
  }
}
