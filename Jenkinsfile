#!groovy
node {
    try {
        stage ('Checkout') {
            deleteDir()
            checkout scm
            bat 'set'            
        }

        stage ('Build') {
            timeout(time: 2, unit: 'MINUTES')  {
                bat "\"${tool 'MSBuild'}\" single-pipeline-demo.sln"
            }            
        }
        stage ('Create container') {
            PowerShell (".\\CreateContainer.ps1")
        }

        stage ('Deploy') {
            PowerShell (".\\Deploy.ps1")
        }

        stage ('Test') {
          PowerShell ("Invoke-Pester -EnableExit -OutputFile single-pipeline-test.xml -OutputFormat NUnitXML")
        }
    }
    catch (e) {
        currentBuild.result = "failed"
        notifyBuild(currentBuild.result)        
        throw e
    } finally {
        stage ('Cleanup') {
            PowerShell (".\\Cleanup.ps1")
        }
        
    }
}


def notifyBuild(String buildStatus) {
  // build status of null means succeeded
  buildStatus =  buildStatus ?: 'succeeded'

  def subject = "Jenkins Job '${env.JOB_NAME}' (${env.BUILD_NUMBER}) ${buildStatus}"
  def colour = 'RED'
  def colorCode = '#FF0000'
  def mainBranches = 'master release hotfix'
  
  if (buildStatus == 'succeeded') {
    colour = 'GREEN'
    colorCode = '#00FF00'
  } 

  emailext (
    attachLog: true,
    compressLog: true,
    subject: subject,
    to: '$DEFAULT_RECIPIENTS',
    body: '$DEFAULT_CONTENT'
  )
  
  if (mainBranches =~ BRANCH_NAME ) {
    slackSend (color: colorCode, message: subject)
  }
}

def PowerShell (psCmd) {
    bat "powershell.exe -NonInteractive -Command \"\$ErrorActionPreference='Stop';$psCmd"
}