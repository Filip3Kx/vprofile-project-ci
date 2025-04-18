def COLOR_MAP = [
    'SUCCES': 'good',
    'FAILURE': 'danger',
]
pipeline {
  environment {
    git_repo = 'https://github.com/Filip3Kx/vprofile-project-ci'
    git_branch = 'main'
    sonar_server = 'sonar_server'
    docker_registry = "192.168.1.20:8082"
    docker_reg_latest = "192.168.1.20:8082/vprofile:latest"
    docker_reg_build_id = "192.168.1.20:8082/vprofile:${env.BUILD_ID}"
  }
  agent any
  tools {
    maven "maven"
    jdk "jdk11"
  }
  stages {
    stage('Fetch Code') {
      steps { 
        git branch: "${git_branch}", url: "${git_repo}"
      }
    }
    stage('Build') {
      steps {
        sh 'mvn install -DskipTests'
      }
    }
    stage('Unit Test') {
      steps {
        sh 'mvn test'
      }
    }
    stage('Checkstyle code analysis') {
        steps {
            sh 'mvn checkstyle:checkstyle'
        }
    }
    stage('SonarQube code analysis') {
        environment {
            scannerHome = tool 'sonar4.8'
        }
        steps {
            withSonarQubeEnv("${sonar_server}") {
                sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=vprofile \
                -Dsonar.projectName=vprofile \
                -Dsonar.projectVersion=1.0 \
                -Dsonar.sources=src/ \
                -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                -Dsonar.junit.reportPath=target/surefire-reports/ \
                -Dsonar.jacobo.report.reportPath=target/jacobo.exec \
                -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml \
                '''
            }
        }
    }
    stage("Quality gate"){
        steps{
            timeout(time: 1, unit: 'HOURS') {
                waitForQualityGate abortPipeline: true
            }
        }
    }
    stage("Docker cleanup") {
      steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
          sh 'docker rm -vf $(docker ps -aq)'
          sh 'docker rmi -f $(docker images -aq)'
        }
      }
    }
    stage("Build & Publish docker image") {
      steps {
        withCredentials([usernamePassword(credentialsId: 'nexus', passwordVariable: 'NEXUS_PASSWORD', usernameVariable: 'NEXUS_USERNAME')]) {
          sh "docker login -u $NEXUS_USERNAME -p $NEXUS_PASSWORD ${docker_registry}"
        }
        sh 'docker build -t vprofileapp .'
        sh "docker tag vprofileapp ${docker_reg_build_id}"
        sh "docker push ${docker_reg_build_id}"
        sh "docker tag vprofileapp ${docker_reg_latest}"
        sh "docker push ${docker_reg_latest}"
      }
    }
  }
  post {
    always {
      echo 'Slack Notification'
      slackSend channel: '#jenkins-notifications',
        color: COLOR_MAP[currentBuild.currentResult],
        message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"
    }
  }
}
