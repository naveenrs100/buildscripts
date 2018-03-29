
#!/bin/ksh
set -vx
lscmPath=/apps/builds/jazz/scmtools/eclipse
MAVEN_HOME=/apps/build/apache-maven-3.5.0
ANT_HOME=/apps/build/apache-ant-1.10.1
CATALINA_HOME=/apps/build/apache-tomcat-8.5.23
export JAVA_HOME=/apps/build/jdk1.8.0_144
JRE_HOME=/apps/build/jdk1.8.0_144/jre
JENKINS_HOME=/apps/build/buildadmin-HOME/.jenkins
udclient=/apps/udclient
weburl=https://ucd.kp.org:8443
SONAR_HOME=/apps/build/sonarqube-6.0
SCM_CONFIG_DIRECTORY=/apps/builds/jazz/scmtools/eclipse/.jazz-scm
PATH=${PATH}:$HOME/bin:${ANT_HOME}/bin:${MAVIN_HOME}/bin:${JAVA_HOME}/bin:/apps/build/jazz/scmtools/eclipse:${udclient}:${SCM_CONFIG_DIRECTORY}
#stream="National_Interfaces_Development"
#export stream
export CATALINA_HOME
export ANT_HOME
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
logfile=${JunitlogFileName}
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
mvn -f "${projectLocation}/pom.xml" cobertura:cobertura >> ${logfile} 2>&1
STATUS=$?
if [ $STATUS -ne 0 ]; then
    log "Junit Failed and email is sent...!"
    sendEmail "$emailid" "***FAILED***AUTO-JUNIT-FAILED-FOR-${tempCom}" "${logfile}" "${logfile}"
#    usage "Error"
fi
echo "Finished sucessfully"
