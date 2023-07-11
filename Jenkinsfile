pipeline {
  agent any 
  tools {
    maven "maven"
    jdk "jdk11"
  }
  stages {
    stage('Fetch Code') {
      steps { 
        git branch: 'vprofile-jenkins-ci', url: 'https://github.com/Filip3Kx/vprofile-project-practice'
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
    stage("Prepare Artifact") {
      steps {
        sh 'mv target/vprofile-v2.war target/vprofile-${BUILD_ID}.war'
      }
      post {
        success {
            echo 'Archiving artifacts...'
            archiveArtifacts artifacts: '**/*.war'
        }
      }
    }
  }
}
