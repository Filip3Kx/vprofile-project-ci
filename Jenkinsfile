pipeline {
  agent any 
  tools {
    maven "maven"
    jdk "jdk11"
  }
  stages {
    stage('Fetch Code') {
      steps { 
        git branch: 'vprofile-jenkins', url: 'https://github.com/Filip3Kx/vprofile-project-practice'
      }
    }
    stage('Build') {
      steps {
        sh 'mvn install -DskipTests'
      }
      post {
        success {
            echo 'Archiving artifacts...'
            archiveArtifacts artifacts: '**/*.war'
        }
      }
    }
    stage('UNIT TESTS') {
      steps {
        sh 'mvn test'
      }
    }
  }
}
