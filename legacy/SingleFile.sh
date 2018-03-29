
#!/bin/ksh
set -vx

#*******************************************************************************
#
#  Use this script to start the RTC Build on AIX and Linux on Power.
#
#  Usage:
#     /apps/build/jazz/scmtools/eclipse/JenTest.sh "/apps/build/jazz/scmtools/eclipse/job-config/accumsui.cfg"
#
#
#  Where:
#     First argument i.e. $1 is the stream          --> RTC Steams such as National_Interfaces_Development
#     Second argument i.e. $2 is the component      --> Name of component of the above stream
#     Third argument i.e. $3 user                   --> RTC userID which is licensed to build
#     Fourth argument i.e. $4 password              --> RTC PASSWORD for this RTC user
#     Fifth argument i.e. $5 isdeleteworkspace      --> value 1 to delete the workspace after build
#     Fifth argument i.e. $6 isStream               --> value 1 mean Stream, 0 means a snapshot
#
#  Example of usage:
#     sh build_RTC_accumsUI.sh "National_Interfaces_Development" "Accums - NW" K832077 <RTC Password> 1 1
#
#
#
# @ Palash Kar
# Email: Palash.Kar@kp.org
# -----------------------------------------------------------
lscmPath=/apps/build/jazz/scmtools/eclipse
MAVEN_HOME=/apps/build/apache-maven-3.5.0
ANT_HOME=/apps/build/apache-ant-1.10.1
CATALINA_HOME=/apps/build/apache-tomcat-8.5.23
JAVA_HOME=/apps/build/jdk1.8.0_144
JRE_HOME=/apps/build/jdk1.8.0_144/jre
JENKINS_HOME=/apps/build/buildadmin-HOME/.jenkins
udclient=/apps/udclient
weburl=https://ucd.kp.org:8443
SCM_CONFIG_DIRECTORY=/apps/build/jazz/scmtools/eclipse/.jazz-scm

SCM_CONFIG_DIRECTORY=/apps/build/jazz/scmtools/eclipse/.jazz-scm
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

#source $lscmPath/lscm.sh

# Read .properties from the input
echo "Input File Name: $1"
. $1

cTime=`date +%m%d%y_%H%M%S`
logfile=${logFileName}
echo $logFile
DATE_STRING=$(date +"%D %T")

function log {
        if test ${logfile}; then
                echo "$DATE_STRING - $*" | tee -a ${logfile}
        fi
}

function usage {
    echo ""
    echo "Usage:"
    echo "${1} {-s RTC_Stream_Name | RTC_SanpShot} {-c RTC Component}"
    echo " {-u RTC_user_login_id} {-p password} -d {y|Y|n}N}"
    echo "Example:"
    echo "${1} -s National_Interfaces_Development -c "Accums - NW""
    echo "  -u K832077 -p <Password> -d Y"
    exit 1
}

function delete_ws {
   log "Deleting  WorkSpace : $1 ....."
   lscm workspace delete "$1" -r jazz >> ${logfile} 2>&1
   log  "cmd: lscm workspace delete "$1" "
}

function logout_rtc {
  lscm logout -r https://rational.kp.org/ccm2
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
##################### Start Here #######################

if  [ -z "${stream}" ] || [ -z "${component}" ] || [ -z "${user}" ] || [ -z "${pword}" ]
then
        usage ${1}
fi

echo ""
while getopts :s:c:u:p:d: script_arg
do
  case $script_arg in
    s)  export stream=$OPTARG;log "getopts stream=$OPTARG";;
    c)  export component=$OPTARG;log "getopts component=$OPTARG";;
    u)  export user=$OPTARG;log "getopts user=$OPTARG";;
    p)  export pword=$OPTARG;log "getopts pword=xxxxx";;
    #d)         export del_ws=$OPTARG;log "getopts del_ws=$OPTARG";;
    *)  usage ${0};;
  esac
done

host=`hostname`
log ${host}

buildPath=${JENKINS_HOME}/workspace/${ITEM_FULLNAME}/${JOB_NAME}
cd $buildPath


# remove the log if present
if test ${logfile}; then
    log "deleting existing log file...."
    rm -f ${logfile}
fi

repo_ws=rtc_scm_${stream}_${component}_$cTime
logout_rtc ## this issue needs to be fixed
log "cmd: lscm login -r https://rational.kp.org/ccm2 -u $user -P xxxx  -n jazz"
lscm login -r https://rational.kp.org/ccm2 -u $user -P $pword -n jazz
RETURN_STATUS=$?
if [ $RETURN_STATUS -ne 0 ]; then
        log "Unable to login to RTC"
        exit 1
fi


log "${emailid} -- ${earFileName} -- ${projectLocation}"
echo "${emailid} -- ${earFileName} -- ${projectLocation}"

tempStream="National_Interfaces_Development"
if [ "$stream" == "$tempStream" ]
then
    tempStream="National_Interfaces_Development"
else
    stream=$stream
    tempStream=$stream
fi



if [ -z "$region" ];
then
                echo "Assigning Region Name : national"
                region = "national"
else
                echo "Region Name present in configuration : ${region}"
fi
echo "Region Name : ${region}"


echo $SNAPSHOT_NAME
if [ -z "$SNAPSHOT_NAME" ];
then
                log "cmd:lscm create workspace -s $stream "${repo_ws}" -r jazz"
                wks_list=`lscm create workspace -s $stream "${repo_ws}" -r jazz`
                wks_exist='echo "$wks_list" | grep "successfully created"'

else
                log "cmd:lscm create workspace ---snapshot ${SNAPSHOT_NAME} "${repo_ws}" -r jazz"
                wks_list=`lscm create workspace --snapshot ${SNAPSHOT_NAME}  "${repo_ws}" -r jazz`
                wks_exist='echo "$wks_list" | grep "successfully created"'
fi



if [ -z "$wks_exist" ];
then
         log "workspace ${repo_ws} could not create in the RTC"
         logout_rtc
         exit 1
fi

stream=$tempStream
log "cmd: lscm load -f -r jazz $repo_ws $component -t ${stream}"
lscm load -f -r jazz "${repo_ws}" "${component}" -t ${stream}

buildPath=${JENKINS_HOME}/workspace/${ITEM_FULLNAME}/${JOB_NAME}/${stream}
echo $buildPath
cd $buildPath
echo $projectLocation
echo $FileName
echo $FilePath
echo "$projectLocation/$component/$FilePath/$FileName"
echo $NCRM
echo $RContent
# Code review demo1
export ArtifacT=/apps/build/jfrog
#cp -p $earFileCopyTo/$earFileName $earFileCopyTo/$TempFile1.$EARorWAR
#$projectLocatio/$FileName/$FilePath
/apps/build/jfrog rt u  --url https://artifactory-bluemix.kp.org/artifactory/ --apikey AKCp5ZkxbpPmw8q6RcKyo8Aqug7SqEVt4pWghBy5tKn7dyX9x1WAj1kJEgatjXCHkUB9DaMhu $projectLocation/$component/$FilePath/$FileName kpcc-staging/$NCRM/$RContent/$component/$FilePath/
echo $repo_ws
delete_ws $repo_ws
logout_rtc
echo "Finished Sucessfully"
