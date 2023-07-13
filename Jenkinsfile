pipeline {
  agent any 
  tools {
    maven "maven"
    jdk "jdk11"
  }
  stages {
    stage('Fetch Code') {
      steps { 
        git branch: 'vprofile-jenkins-ci', url: 'https://github.com/Filip3Kx/vprofile-project-ci'
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
            withSonarQubeEnv('sonar_server') {
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
    stage("Upload artifact to nexus") {
      steps {
        nexusArtifactUploader(
          nexusVersion: 'nexus3',
          protocol: 'http',
          nexusUrl: '192.168.1.20:8081',
          groupId: 'QA',
          version: "${env.BUILD_ID}",
          repository: 'vprofile-artifacts',
          credentialsId: 'nexus',
          artifacts: [
            [artifactId: 'vprofile-pipeline',
            classifier: '',
            file: 'target/vprofile-v2.war',
            type: 'war']
          ]
        )
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
