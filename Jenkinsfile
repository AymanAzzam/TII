pipeline {
  agent {
    kubernetes {
      label 'hextris-agent'
      defaultContainer 'jnlp'
      yaml """
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    command:
    - cat
    tty: true
    volumeMounts:
    - name: kaniko-docker-config
      mountPath: /kaniko/.docker
  - name: kubectl
    image: bitnami/kubectl:1.29.0
    command:
    - cat
    tty: true
  volumes:
  - name: kaniko-docker-config
    secret:
      secretName: regcred
"""
    }
  }

  environment {
    REGISTRY = "docker.io/YOUR_DOCKER_USER"
    IMAGE = "hextris"
    TAG = "${env.BUILD_NUMBER}"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build & Push (Kaniko)') {
      steps {
        container('kaniko') {
          // kaniko uses /workspace as default context; plugin maps workspace inside pod at /workspace
          sh '''
            /kaniko/executor \
              --context $WORKSPACE \
              --dockerfile $WORKSPACE/Dockerfile \
              --destination $REGISTRY/$IMAGE:$TAG \
              --cleanup
          '''
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        container('kubectl') {
          // If your kubectl in the pod uses the same credentials as the Kubernetes plugin,
          // kubectl should be able to talk to the cluster. Otherwise use kubeconfig credentials.
          sh """
            kubectl set image deployment/hextris-deployment \
              hextris=${REGISTRY}/${IMAGE}:${TAG} --record
            kubectl rollout status deployment/hextris-deployment --timeout=120s
          """
        }
      }
    }
  }

  post {
    success {
      echo "Deployed ${REGISTRY}/${IMAGE}:${TAG}"
    }
    failure {
      echo "Build or Deploy failed"
    }
  }
}
pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    command:
    - cat
    tty: true
    volumeMounts:
      - name: docker-config
        mountPath: /kaniko/.docker/
  - name: helm
    image: alpine/helm:3.12.3
    command:
    - cat
    tty: true
  - name: kubectl
    image: bitnami/kubectl:1.28
    command:
    - cat
    tty: true
  volumes:
    - name: docker-config
      projected:
        sources:
        - secret:
            name: dockerhub-cred
            items:
              - key: .dockerconfigjson
                path: config.json
"""
    }
  }

  environment {
    REGISTRY = "docker.io/aymanazzam63"
    IMAGE    = "hextris"
    TAG      = "build-${env.BUILD_NUMBER}"
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/AymanAzzam/TII.git'
      }
    }

    stage('Build & Push with Kaniko') {
      steps {
        container('kaniko') {
          sh """
            /kaniko/executor \
              --context `pwd`/app \
              --dockerfile `pwd`/app/Dockerfile \
              --destination $REGISTRY/$IMAGE:$TAG \
              --cleanup
          """
        }
      }
    }

    stage('Deploy with Helm') {
      steps {
        container('helm') {
          withCredentials([file(credentialsId: 'kubeconfig-cred', variable: 'KUBECONFIG')]) {
            sh """
              helm upgrade --install hextris ./hextris-chart \
                --set image.repository=$REGISTRY/$IMAGE \
                --set image.tag=$TAG \
                --kubeconfig $KUBECONFIG
            """
          }
        }
      }
    }
  }
}
