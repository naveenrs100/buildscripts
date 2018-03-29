// Pipeline script for Support Console (national_UI) Application

properties([[
	$class: 'EnvInjectJobProperty', 
	info: [
		loadFilesFromMaster: false, 
		propertiesContent: 'AppName=Support_Console', 
		secureGroovyScript: [classpath: [], sandbox: false, script: '']],
	keepBuildVariables: true, 
	keepJenkinsSystemVariables: true, 
	on: true
]])

pipeline {
	agent {
		label {
			label "kpcc"
			customWorkspace "/apps/build/buildadmin-HOME/.jenkins/workspace/KPCC_CI_SCM_CheckOut/${AppName}/"
		}
	}
    stages {
		stage('Initialization') {
            steps {
                echo 'Current Stage: Initialization'
				checkout([
					$class: 'GitSCM', 
					branches: [[name: '*/master']], 
					doGenerateSubmoduleConfigurations: false, 
					extensions: [[$class: 'CleanBeforeCheckout'], [$class: 'RelativeTargetDirectory', relativeTargetDir: 'build_scripts']], 
					submoduleCfg: [], 
					userRemoteConfigs: [[credentialsId: 'GIT-svcTPSTci', url: 'https://github.kp.org/HP-BIO-ClaimsConnect/KPCC-Build.git']]
				])
				load "${workspace}/build_scripts/build/configs/${AppName}.properties"
				echo "AppName: ${AppName}"
				echo "stream: ${stream}"
				echo "projectLocation: ${projectLocation}"
				echo "component: ${component}"
            }
        }
        stage('KPCC_CI_SCM_CheckOut') {
            steps {
                echo 'Current Stage: KPCC_CI_SCM_CheckOut'                
				echo "projectLocation: ${projectLocation}"
				echo "component: ${component}"
				git(
					url: 'https://github.kp.org/HP-BIO-ClaimsConnect/${AppName}.git',
					credentialsId: 'GIT-svcTPSTci',
					branch: "${env.BRANCH_NAME}"
				)
            }
        }
        stage('KPCC_CI_Junit') {
            steps {
                echo 'Current Stage: KPCC_CI_Junit'
				echo "projectLocation: ${projectLocation}"
				echo "component: ${component}"
                withEnv([
                    "env_projectLocation=${projectLocation}"    
                ]){
					sh 'mvn -f "$env_projectLocation/pom.xml" cobertura:cobertura -Dmaven.test.skip=true'
                }
            }
        }
       
	    stage('KPCC_CI_Sonar') {
			steps {
                echo 'Current Stage: KPCC_CI_Sonar'
				echo "projectLocation: ${projectLocation}"
				echo "component: ${component}"
               withEnv([
                   "env_projectLocation=${projectLocation}"    
               ]){
					echo "projectLocation: ${env_projectLocation}"
					withSonarQubeEnv('Sonar2118'){
						sh 'mvn -f ${env_projectLocation}/pom.xml sonar:sonar'
					}
			   }
            }
        }
        stage('KPCC_CI_Build') {
			steps {
                echo 'Current Stage: KPCC_CI_Build'
                withEnv([
                    "env_projectLocation=${projectLocation}"    
                ]){
					sh 'mvn -f "${env_projectLocation}/pom.xml" clean install -Djavax.xml.accessExternalSchema=all -Dmaven.test.skip=true'
				}
            }
        }
        stage('KPCC_CI_Artifactory') {
			steps {
                echo 'Current Stage: KPCC_CI_Artifactory'
				sh 'cd ${Base_Artifact_Directory}'
				script {
					def server = Artifactory.server 'Artifact-1'
					def uploadSpec = """{
					  "files": [
						{
						  "pattern": "${Base_Artifact_Directory}/(*).jar",
						  "target": "kpcc-staging/${component}/java/",
							"props": "Release=value1;Release_Content=value2",
							"recursive": "false",
							"flat" : "true"
						},
						{
						  "pattern": "${Base_Artifact_Directory}/(*).war",
						  "target": "kpcc-staging/${component}/java/",
							"props": "Release=value1;Release_Content=value2",
							"recursive": "false",
							"flat" : "true"
						},
						{
						  "pattern": "${Base_Artifact_Directory}/(*).ear",
						  "target": "kpcc-staging/${component}/java/",
							"props": "Release=value1;Release_Content=value2",
							"recursive": "false",
							"flat" : "true"
						}					
					 ]
					}"""
					//server.upload(uploadSpec)
				//	server.upload spec: uploadSpec
					def buildInfo = server.upload spec: uploadSpec
					server.publishBuildInfo buildInfo
				}
			}
		}
        stage('KPCC_CI_UCD') {
			steps {
				//mail (to: 'shashikanth.ragula@kp.org', subject: "Job '${env.JOB_BASE_NAME}' (${env.BUILD_NUMBER}) is waiting for input", body: "Please go to console output of ${env.BUILD_URL}/input to approve or Reject.");
//                mail (to: 'shashikanth.ragula@kp.org', subject: "Awaiting Input: Job '${env.JOB_BASE_NAME}' [Build: ${env.BUILD_NUMBER}] requires approval to continue", mimeType: "text/html", body: " <p> Job '${env.JOB_BASE_NAME}' [Build: ${env.BUILD_NUMBER}] is awaiting your approval to initiate DIT deployment. <br><br> Follow this link to approve or reject: ${env.BUILD_URL}/input <br> </p>");
 //               input message: 'Deploy to DIT?', submitter: 'e453004', submitterParameter: 'approver'
                
        		script {
        		    emailext mimeType: 'text/html',
                    subject: "[Jenkins]${currentBuild.fullDisplayName} Awaiting Input: Requires approval to continue",
                    to: "shashikanth.ragula@kp.org",
                    body: '''<a href="${BUILD_URL}input">Click to approve</a>'''
                 
        			userInput = input message: 'User input required',
        			submitterParameter: 'submitter',
        			submitter: 'e453004',
        					parameters: [choice(name: 'ENVIRONMENT', choices: 'DIT\nSIT\nUAT', description: 'What Environment to deploy on?'),choice(name: 'REGION', choices: 'NCAL\nSCAL\nCO\nGA\nHI\nMA\nNW', description: 'What Region to deploy to?')]
				}				
				
				
				echo 'Current Stage: KPCC_CI_UCD'
				withEnv([
					"env_workspace=${workspace}",
					"env_AppName=${AppName}",
                    "env_projectLocation=${projectLocation}",
					"env_Base_Artifact_Directory=${Base_Artifact_Directory}"
                ]){
					sh 'BUILD_VERSION=\"`mvn -f "${env_projectLocation}/pom.xml" help:evaluate -Dexpression=project.version | grep -v "\\["`\"; echo -n "BUILD_VERSION=\\"$BUILD_VERSION\\"" >> ${env_workspace}/build_scripts/build/configs/${env_AppName}.properties'
					sh 'cd $env_Base_Artifact_Directory ; arft=`find . -maxdepth 1 -name "*.ear" -o -name "*.war" -o -name "*.jar"`; arft=`basename $arft`; arft_name=${arft%.*};arft_type=${arft##*.}; echo "\narft_name=\\"$arft_name\\"" >> ${env_workspace}/build_scripts/build/configs/${env_AppName}.properties; echo "arft_type=\\"$arft_type\\"" >> ${env_workspace}/build_scripts/build/configs/${env_AppName}.properties'
				}
				load "${workspace}/build_scripts/build/configs/${AppName}.properties"
				echo "BUILD_VERSION: ${BUILD_VERSION}"
				
			   //Publish artifacts to UCD

			   step([$class: 'UCDeployPublisher',
				//	altUser: [altPassword: hudson.util.Secret.fromString('${pword}'), altUsername: 'rational.jazz.builduser.Tapestry'],
					siteName: 'rational.jazz.builduser.Tapestry',
					component: [
						$class: 'com.urbancode.jenkins.plugins.ucdeploy.VersionHelper$VersionBlock',
						componentName: "${UC}",
						createComponent: [
							$class: 'com.urbancode.jenkins.plugins.ucdeploy.ComponentHelper$CreateComponentBlock',
							componentTemplate: '',
							componentApplication: "${UCD_DA}"
						],
						delivery: [
							$class: 'com.urbancode.jenkins.plugins.ucdeploy.DeliveryHelper$Push',
							pushVersion: "${arft_name}.${env.BUILD_NUMBER}",
							baseDir: "${Base_Artifact_Directory}",
							fileIncludePatterns: "*.${arft_type}",
							fileExcludePatterns: '',
							pushProperties: "UCD_FILE_NAME=${arft_name}",
							pushDescription: "Published from Jenkins Pipeline: ${env.BUILD_NUMBER}",
							pushIncremental: false
						]
					]
				])
            }
        }
		stage('KPCC_CI_Deploy2DIT') {
			steps {
				echo 'Current Stage: KPCC_CI_Deploy2DIT'
				echo "projectLocation: ${projectLocation}"
				echo "UCD_DA: ${UCD_DA}"
              withEnv([
					"env_workspace=${workspace}",
					"env_component=${component}",
					"env_UC=${UC}",
					"env_UCD_DA=${UCD_DA}",
					"env_UCD_DE=${UCD_DE}",
					"env_UCD_Process=${UCD_Process}",
					"env_arft_name=${arft_name}",
					"env_arft_type=${arft_type}",
					"env_DeployEnv=${userInput['ENVIRONMENT']}",
					"env_DeployRegion=${userInput['REGION']}"
                ]){
//					sh "${env_workspace}/build_scripts/build/scripts/jenkins/KPCC_CI_UCD_deploy_v3.sh ${env_UCD_DA} ${env_UC} ${env_UCD_DE}" 
					sh "/apps/build/udclient/KPCC_CI_UCD_deploy_dummy.sh ${env_UCD_DA} ${env_UC} ${env_UCD_DE} ${env_component} ${env_arft_name} ${env_arft_type} ${env_DeployEnv} ${env_DeployRegion}" //temp change to test artifactory prop updates
				}
			}
		}
	}
	post {
		success {
		  emailext (
			  subject: "SUCCESSFUL: Pipeline for '${AppName} [Build: ${env.BUILD_NUMBER}]'",
			  mimeType: 'text/html',
			  body: """<p>SUCCESSFUL: Pipeline for '${AppName} [Build: ${env.BUILD_NUMBER}]':</p>
				<br><table bgcolor="#6B8E23" border="1"><tr><td>Application</td><td>${AppName}</td></tr><tr><td>Stream</td><td>${stream}</td></tr></table><br>
				<p>For complete details, check console output <a href='${env.BUILD_URL}/console'>here</a></p>""",
			  to: 'shashikanth.ragula@kp.org'
			)
		}
		failure {
			emailext (
			  subject: "FAILURE: Pipeline for '${AppName} [Build: ${env.BUILD_NUMBER}]'",
			  mimeType: 'text/html',
			  body: """<p>FAILURE: Pipeline for '${AppName} [Build: ${env.BUILD_NUMBER}]':</p>
				<br><table bgcolor="#FF4500" border="1"><tr><td>Application</td><td>${AppName}</td></tr><tr><td>Stream</td><td>${stream}</td></tr></table><br>
				<p>For complete details, check console output <a href='${env.BUILD_URL}/console'>here</a></p>""",
			  to: 'shashikanth.ragula@kp.org'
			)
		}
	}
}
