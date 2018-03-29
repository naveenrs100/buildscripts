
#!/bin/ksh
set -vx
lscmPath=/apps/builds/jazz/scmtools/eclipse
MAVEN_HOME=/apps/build/apache-maven-3.5.0
ANT_HOME=/apps/build/apache-ant-1.10.1
CATALINA_HOME=/apps/build/apache-tomcat-8.5.23
JAVA_HOME=/apps/build/jdk1.8.0_144
JRE_HOME=/apps/build/jdk1.8.0_144/jre
JENKINS_HOME=/users/buildadmin/.jenkins
udclient=/apps/udclient
weburl=https://ucd.kp.org:8443
SONAR_HOME=/apps/build/sonarqube-6.0
SCM_CONFIG_DIRECTORY=/apps/builds/jazz/scmtools/eclipse/.jazz-scm
PATH=${PATH}:$HOME/bin:${ANT_HOME}/bin:${MAVIN_HOME}/bin:${JAVA_HOME}/bin:/apps/build/jazz/scmtools/eclipse:${udclient}:${SCM_CONFIG_DIRECTORY}
#stream="National_Interfaces_Development"
#export stream
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

echo "Input File Name: $1"
. $1
export stream
. $1
logfile=${BuildlogFileName}
echo $logFile

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
echo $stream
if [ -z "$projectversion" ];
then
        projectversion=`mvn -f "${projectLocation}/pom.xml" help:evaluate -Dexpression=project.version | grep -v '\['`
        echo ${projectversion}

fi

log "cmd: mvn -f $projectLocation/pom.xml clean compile package "
#mvn -f "${projectLocation}/pom.xml" clean install -Dmaven.test.skip=true  >> ${logfile} 2>&1

if [[ $AppName = "Claim_Inventory" ]]; then
	mvn -f "${projectLocation}/pom.xml" clean install -Dmaven.test.skip=true  >> ${logfile} 2>&1
elif [[ $AppName = "Support_Console" ]]; then
	mvn -f "${projectLocation}/pom.xml" clean install -Dmaven.test.skip=true  >> ${logfile} 2>&1
elif [[ $AppName = "PDF_Utility" ]]; then
	mvn -f "${projectLocation}/pom.xml" clean install -Dmaven.test.skip=true  >> ${logfile} 2>&1
elif [[ $AppName = "OCI_CAQHUpdate" ]]; then
	mvn -f "${projectLocation}/pom.xml" clean install -Dmaven.test.skip=true  >> ${logfile} 2>&1
elif [[ $AppName = "Common_Extract" ]]; then
	mvn -f "${projectLocation}/pom.xml" clean install -Dmaven.test.skip=true  >> ${logfile} 2>&1
elif [[ $AppName = "Accums_CompositeService" ]]; then
	mvn -f "${projectLocation}/pom.xml" clean install -Dmaven.test.skip=true  >> ${logfile} 2>&1
elif [[ $AppName = "Accums" ]]; then
	mvn -f "${projectLocation}/pom.xml" clean install -Djavax.xml.accessExternalSchema=all -Dmaven.test.skip=true  >> ${logfile} 2>&1
elif [[ $AppName = "OCI_837ClaimValidator" ]]; then
	mvn -f "${projectLocation}/pom.xml" clean install -Dmaven.test.skip=true  >> ${logfile} 2>&1
elif [[ $AppName = "accumulations-outbound-delta" ]]; then
	mvn -f "${projectLocation}/pom.xml" clean install -Djavax.xml.accessExternalSchema=all -Dmaven.test.skip=true  >> ${logfile} 2>&1
elif [[ $AppName = "accumulations-outbound-cmk" ]]; then
	mvn -f "${projectLocation}/pom.xml" clean install -Djavax.xml.accessExternalSchema=all -Dmaven.test.skip=true  >> ${logfile} 2>&1
elif [[ $AppName = "accumulations-outbound-mi" ]]; then
	mvn -f "${projectLocation}/pom.xml" clean install -Djavax.xml.accessExternalSchema=all -Dmaven.test.skip=true  >> ${logfile} 2>&1
elif [[ $AppName = "OCI_Revalidator_UI" ]]; then
	mvn -f "${projectLocation}/pom.xml" clean install -Dmaven.test.skip=true  >> ${logfile} 2>&1
elif [[ $AppName = "OCI_DataMiningValidator" ]]; then
	mvn -f "${projectLocation}/pom.xml" clean install -Dmaven.test.skip=true  >> ${logfile} 2>&1
elif [[ $AppName = "OCI_CommonComponent" ]]; then
	mvn -f "${projectLocation}/pom.xml" clean install -Dmaven.test.skip=true  >> ${logfile} 2>&1
elif [[ $AppName = "OCI_CommonWS" ]]; then
	mvn -f "${projectLocation}/pom.xml" clean install -Djavax.xml.accessExternalSchema=all -Dmaven.test.skip=true  >> ${logfile} 2>&1
elif [[ $AppName = "DASP" ]]; then
	mvn -f "${projectLocation}/pom.xml" clean install -Djavax.xml.accessExternalSchema=all -Dmaven.test.skip=true  >> ${logfile} 2>&1
elif [[ $AppName = "Incident_Utility" ]]; then
        mvn -f "${projectLocation}/pom.xml" clean install -Dmaven.test.skip=true  >> ${logfile} 2>&1
elif [[ $AppName = "Print_Consolidator" ]]; then
        mvn -f "${projectLocation}/pom.xml" clean compile -Dmaven.test.skip=true package  >> ${logfile} 2>&1
fi

STATUS=$?
if [ $STATUS -ne 0 ]; then
    log "Maven build Failed and email is sent...!"
    sendEmail "$emailid" "***FAILED***AUTO-BUILD-MAVEN-FAILED-FOR-${tempCom}" "${logfile}" "${logfile}"
    delete_ws $repo_ws
    logout_rtc
    usage "Error"
fi

echo "Finished sucessfully"
