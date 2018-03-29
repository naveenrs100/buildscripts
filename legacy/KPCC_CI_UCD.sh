
#!/bin/ksh
#set -vx
lscmPath=/apps/builds/jazz/scmtools/eclipse
MAVEN_HOME=/apps/build/apache-maven-3.5.0
ANT_HOME=/apps/build/apache-ant-1.10.1
CATALINA_HOME=/apps/build/apache-tomcat-8.5.23
JAVA_HOME=/apps/build/jdk1.8.0_144
JRE_HOME=/apps/build/jdk1.8.0_144/jre
JENKINS_HOME=/apps/build/buildadmin-HOME/.jenkins
udclient=/apps/udclient
weburl=https://ucd.kp.org:8443
SONAR_HOME=/apps/build/sonarqube-6.0
SCM_CONFIG_DIRECTORY=/apps/builds/jazz/scmtools/eclipse/.jazz-scm
PATH=${PATH}:$HOME/bin:${ANT_HOME}/bin:${MAVIN_HOME}/bin:${JAVA_HOME}/bin:/apps/build/jazz/scmtools/eclipse:${udclient}:${SCM_CONFIG_DIRECTORY}
export CATALINA_HOME
export ANT_HOME
export JAVA_HOME
export PATH
export udclient
export JENKINS_HOME
export SCM_CONFIG_DIRECTORY
export SCM_ALLOW_INSECURE=1
export RTC_SCRIPT_BASE=$lscmPath/Scripts
export RTC_SCRIPT_BASE_Script=$lscmPath/Scripts/unix
export PRGPATH=$lscmPath
export MAVEN_HOME
PATH=$PATH:$JAVA_HOME:$JAVA_HOME/bin:$MAVEN_HOME:$MAVEN_HOME/bin:$ANT_HOME:$ANT_HOME/bin:$PRGPATH:$RTC_SCRIPT_BASE:$SCM_ALLOW_INSECURE:RTC_SCRIPT_BASE_Script:.
export PATH
export MAVEN_OPTS="-Xmx512m"

logfile=${JunitlogFileName}
echo $logFile
echo "Input File Name: $1"
. $1
export stream
. $1
export stream
tempStream="National_Interfaces_Development"
function log {
        if test ${logfile}; then
                echo "$DATE_STRING - $*" | tee -a ${logfile}
        fi
}


sendEmail () {

    echo "sending email, with parameters $1"
    to="$1"
    subject="$2"
    body="$3"
    file="$4"
    #mailx -s "${subject}" "${to}"  < ${logfile}
    log "cmd: java -cp $lscmPath/activation-1.1.jar:$lscmPath/mail-1.4.3.jar:$lscmPath JavaEmail $1 $2 $3 $4"
    java -cp $lscmPath/activation-1.1.jar:$lscmPath/mail-1.4.3.jar:$lscmPath JavaEmail $1 "$2" "$3" $4
}

# remove blank space from component text to display in email send
tempCom=`echo "${component}" | tr -d ' '`
echo ${tempCom}
echo $projectversion
echo $projectLocation

if [ -z "$projectversion" ];
then
        projectversion=`mvn -f "${projectLocation}/pom.xml" help:evaluate -Dexpression=project.version | grep -v '\['`
        echo ${projectversion}

fi
if [ -z "$earFileName" ];
then
    echo 'ear FileName  is NULL.....'
    for entry in "${earTargetLocation}"/*.ear
    do
      if [ -f "$entry" ];then
        echo "$entry"
        #earFileName="${entry}"
        earFileName=`basename "${entry}"`
      fi
    done
fi

if [ -z "$earFileName" ];
then
    echo 'war FileName  is NULL.....'
    for entry in "${earTargetLocation}"/*.war
    do
      if [ -f "$entry" ];then
        echo "$entry"
        #earFileName="${entry}"
        earFileName=`basename "${entry}"`
      fi
    done
fi

if [ -z "$earFileName" ];
then
    echo 'jar FileName  is NULL.....'
    for entry in "${earTargetLocation}"/*.jar
    do
      if [ -f "$entry" ];then
        echo "$entry"
        #earFileName="${entry}"
        earFileName=`basename "${entry}"`
      fi
    done
fi
export earFileName
echo "============================================================================"
echo "earFileName  $earFileName"
echo "============================================================================"



#####################
INJECT_FILENAME=${JENKINS_HOME}/jobs/${JOB_NAME}/builds/${BUILD_NUMBER}/_injectfile.txt
ucdFileSize=`ls -l ${earTargetLocation}/${earFileName} | awk '{print $5}'`
echo ${ucdFileSize}
echo $Base_Artifact_Directory
echo ${Base_Artifact_Directory}
##if [[ "$earFileName" == *.jar ]]
##then
  ## SUBSTRING=$(echo $earFileName| cut -d'.' -f 1)
   ##printf "UCD_VERSION=$SUBSTRING-$projectversion.${BUILD_NUMBER}\nUCD_APPLICATION_NAME=$ucdApplicationName\nUCD_COMPONENT_NAME=$ucdComponentName\nUCD_FILE_NAME=$earFileName\nASSET_NAME=${assetname}\nUCD_FILE_SIZE=${ucdFileSize}\nSTREAM=${tempStream}\nBase_Artifact_Directory=$Base_Artifact_Directory\n" > ${INJECT_FILENAME}
###else
   ##SUBSTRING=$(echo $earFileName| cut -d'-' -f 1)
  ## printf "UCD_VERSION=$SUBSTRING-$projectversion.${BUILD_NUMBER}\nUCD_APPLICATION_NAME=$ucdApplicationName\nUCD_COMPONENT_NAME=$ucdComponentName\nUCD_FILE_NAME=$earFileName\nASSET_NAME=${assetname}\nUCD_FILE_SIZE=${ucdFileSize}\nSTREAM=${tempStream}\nBase_Artifact_Directory=$Base_Artifact_Directory\n" > ${INJECT_FILENAME}
##fi
if [[ "$earFileName" == *.jar ]]
then
   SUBSTRING=$(echo $earFileName| cut -d'.' -f 1)
   printf "UCD_VERSION=$SUBSTRING-$projectversion.${BUILD_NUMBER}\nUCD_APPLICATION_NAME=$ucdApplicationName\nUCD_COMPONENT_NAME=$ucdComponentName\nUCD_FILE_NAME=$earFileName\nASSET_NAME=${assetname}\nUCD_FILE_SIZE=${ucdFileSize}\nSTREAM=${tempStream}\nBase_Artifact_Directory=$Base_Artifact_Directory\nUCD_Component_Jar=$earFileName\nUC=$UC\nUCD_DA=$UCD_DA\nUCD_DE=$UCD_DE\nUCD_Process=$UCD_Process\n" > ${INJECT_FILENAME}
else
   SUBSTRING=$(echo $earFileName| cut -d'-' -f 1)
   printf "UCD_VERSION=$SUBSTRING-$projectversion.${BUILD_NUMBER}\nUCD_APPLICATION_NAME=$ucdApplicationName\nUCD_COMPONENT_NAME=$ucdComponentName\nUCD_FILE_NAME=$earFileName\nASSET_NAME=${assetname}\nUCD_FILE_SIZE=${ucdFileSize}\nSTREAM=${tempStream}\nBase_Artifact_Directory=$Base_Artifact_Directory\nUCD_Component_Jar=$earFileName\nUC=$UC\nUCD_DA=$UCD_DA\nUCD_DE=$UCD_DE\nUCD_Process=$UCD_Process\n" > ${INJECT_FILENAME}
fi
echo "UCD_Component_Jar=$earFileName"
TempFile1=`cat ${INJECT_FILENAME} | grep -i UCD_VERSION | cut -d '=' -f 2`
echo $TempFile1
#EARorWAR=`echo $earFileName | cut -d "." -f 2`
EARorWAR=`printf $earFileName | tail -c 3`
echo $EARorWAR
cp -p $earFileCopyTo/$earFileName $earFileCopyTo/$TempFile1.$EARorWAR

#To clear source code and start afresh for next execution
# rm $BuildPath/$component
echo $BuildPath/$component

#################
echo "Finished Sucessfully"
