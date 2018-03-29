
#!/bin/ksh
set -vx
lscmPath=/apps/builds/jazz/scmtools/eclipse
MAVEN_HOME=/apps/build/apache-maven-3.5.0
ANT_HOME=/apps/build/apache-ant-1.10.1
CATALINA_HOME=/apps/build/apache-tomcat-8.5.23
JAVA_HOME=/apps/build/jre1.8.0_144
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
logfile=${SonarlogFileName}
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
echo $earTargetLocation

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

if [ -z "$earFileName" ];
then
    echo 'Target Artifacts file name is blank or null so deleting workspace and logging out....'
        sendEmail "$emailid" "***BUILD***AUTO-BUILD-MAVEN-FAILED-FOR-${tempCom}" "${logfile}" "${logfile}"
    #delete_ws $repo_ws
    #logout_rtc
    usage "Error"
fi

log "cmd: csum -h MD5 ${earTargetLocation}/${earFileName} >${earFileCopyTo}/${checkSumFileName}"
csum -h MD5 "${earTargetLocation}/${earFileName}" >"${earFileCopyTo}/${checkSumFileName}"

tempfiletimestamp=$(date +"%b-%d-%Y_%H:%M:%S")

#tempEARfilename=`echo ${earFileName} | cut -f1 -d'.'`
tempEARfilename=`echo ${earFileName%.*}`

#tempEARfileExtension=`echo ${earFileName} | cut -d'.' -f2`
tempEARfileExtension=`echo ${earFileName##*.}`

#ramUploadFileName=${tempEARfilename}_${tempfiletimestamp}.zip

log "cmd: cp -rf $earTargetLocation/$earFileName $earFileCopyTo"
chmod 777 "${earTargetLocation}/${earFileName}"
cp -rf "${earTargetLocation}/${earFileName}" "${earFileCopyTo}"

STATUS=$?
if [ -z "$earFileName" ]; then
    log "*** FAILED *** AUTO-BUILD - COPY Artifacts FILE FAILED FOR ${component}"
    sendEmail "$emailid" "***FAILED*** AUTO-BUILD-COPY-Artifacts-FILE-FAILED-FOR-${tempCom}" "${logfile}" "${logfile}"
     
    usage "Error"
fi

if [ -z "$projectversion" ];
then
        projectversion=`mvn -f "${projectLocation}/pom.xml" help:evaluate -Dexpression=project.version | grep -v '\['`
        echo ${projectversion}

fi
echo $projectversion
echo $BuildPath
buildPath=$BuildPath
cd $buildPath
if [ -z "$isFileRename" ]; then
                log "cmd: mv $earFileCopyTo/$earFileName $earFileCopyTo/${tempEARfilename}_${tempfiletimestamp}.${tempEARfileExtension}"
                mv "${earFileCopyTo}/${earFileName}" "${earFileCopyTo}/${tempEARfilename}_${region}_${tempfiletimestamp}.${tempEARfileExtension}"
                echo "${earFileCopyTo}/${tempEARfilename}_${region}_${tempfiletimestamp}.${tempEARfileExtension}"

                log "cmd: sudo chmod 777 ${earFileCopyTo}/${tempEARfilename}_${region}_${tempfiletimestamp}.${tempEARfileExtension}"
                chmod 777 "${earFileCopyTo}/${tempEARfilename}_${region}_${tempfiletimestamp}.${tempEARfileExtension}"


                cd $buildPath
                thisassetname=${assetname}
                if [ -z "${thisassetname}" ];
                then
                        thisassetname=$tempCom
                fi

                if [ -z "${isRamPublish}" ];
                then
                        log "*** NOT publishing to RAM (Rational Asset manager) *** FOR ${component}"
                else
                        generatedTag="${region}_${streamversion}_${deployenv}_${revesion}_${revesiontype}"

                        if test ${earFileCopyTo}/${tempEARfilename}_${region}_${tempfiletimestamp}.${tempEARfileExtension}; then
                                echo "EAR/WAR/JAR Location found: ${earFileCopyTo}/${tempEARfilename}_${region}_${tempfiletimestamp}.${tempEARfileExtension}"
                        fi

                        if test ${buildPath}/${logFileName}; then
                                echo "Log File Location found: ${buildPath}/${logFileName}"
                        fi

                        if test ${earFileCopyTo}/${checkSumFileName}; then
                                echo "checksum File Location found : ${earFileCopyTo}/${checkSumFileName}"
                        fi

                        ant -v -lib /apps/builds/ramclient/ramclient-ant.jar -file /apps/builds/ramclient/ramPublishAssetCdrive.xml -Dram.asset.version="${projectversion}" -Dram.asset.category="${ramcategory}" -Dram.asset.name="${thisassetname}" -Dram.asset.community="Tapestry Develop" -Dram.asset.type="Package Components" -Dram.asset.tag="${generatedTag}" -Dram.asset.description="${thisassetname} Tapestry ${ramcategory} ${deployenv}" -Dram.asset.shortDescription="${thisassetname} Tapestry ${ramcategory} ${deployenv}" -Dram.asset.teamInfo="$emailid" -Dram.asset.artifacts="${earFileCopyTo}/${tempEARfilename}_${region}_${tempfiletimestamp}.${tempEARfileExtension}" -Dram.asset.artifactschecksum="${earFileCopyTo}/${checkSumFileName}"  -Dram.asset.artifactsbuildlog="${buildPath}/${logFileName}" -Dram.asset.guid="1A056E17-E326-A8C5-B72A-39B48EBAE0B5"
                        STATUS=$?
                        if [ $STATUS -ne 0 ]; then
                         log "*** Uploading Artifacts to RAM (Rational Asset manager) FAILED *** FOR ${component}"
                         #delete_ws $repo_ws
                        # logout_rtc
                         usage "Error"
                        fi
                fi

                eMailsBody="TO: ${emailid} # Stream: ${stream} # Component: ${component} # Workspace: ${repo_ws} # Rational Asset Manager : {https://rational.kp.org/ram} # Asset Name: ${thisassetname} # Community: Tapestry Develop  # File Name: ${tempEARfilename}_${tempfiletimestamp}.${tempEARfileExtension} # Date ${DATE_STRING}"
                log "########################### DRF/IRF INFO #############################################################################"
                log "${eMailsBody}"
                log "########################### DRF/IRF INFO #############################################################################"

                cd $buildPath
                sendEmail "${emailid}" "AUTO-BUILD-SUCCESS-FOR-Component:${tempCom}" "$eMailsBody" "${logfile}"
                log "JOB completed successfully, email is sent....."

                log "cmd: rm {earFileCopyTo}/${tempEARfilename}_${region}_${tempfiletimestamp}.${tempEARfileExtension}"
                rm -f "${earFileCopyTo}/${tempEARfilename}_${region}_${tempfiletimestamp}.${tempEARfileExtension}"
else
                log "cmd: mv $earFileCopyTo/$earFileName $earFileCopyTo/${tempEARfilename}_${tempfiletimestamp}.${tempEARfileExtension}"
                #mv "${earFileCopyTo}/${earFileName}" "${earFileCopyTo}"
                echo "${earFileCopyTo}/${earFileName}"
                log "cmd: sudo chmod 777 ${earFileCopyTo}/${earFileName}"
                chmod 777 "${earFileCopyTo}/${earFileName}"

                # zip -j ${earFileCopyTo}/${tempEARfilename}_${region}_${tempfiletimestamp}.${tempEARfileExtension}.zip ${earFileCopyTo}/${tempEARfilename}_${region}_${tempfiletimestamp}.${tempEARfileExtension}
                # STATUS=$?
                # if [ $STATUS -ne 0 ]; then
                 # log "*** ZIP FAILED *** AUTO-BUILD - COPY Artifacts FILE FAILED FOR ${earFileCopyTo}/${tempEARfilename}_${region}_${tempfiletimestamp}.${tempEARfileExtension}"
                 # delete_ws $repo_ws
                 # logout_rtc
                 # usage "Error"
                # fi

                #chmod 777 "${earFileCopyTo}/${tempEARfilename}_${region}_${tempfiletimestamp}.${tempEARfileExtension}.zip"


                cd $buildPath
                #chmod -R 777 /tmp/com.ibm.ram.ant/*.*

                #echo "${earFileCopyTo}/${tempEARfilename}_${region}_${tempfiletimestamp}.${tempEARfileExtension}.zip"

                thisassetname=${assetname}
                if [ -z "${thisassetname}" ];
                then
                        thisassetname=$tempCom
                fi

                if [ -z "${isRamPublish}" ];
                then
                        log "*** NOT publishing to RAM (Rational Asset manager) *** FOR ${component}"
                else
                        generatedTag="${region}_${streamversion}_${deployenv}_${revesion}_${revesiontype}"

                        if test ${earFileCopyTo}/${earFileName}; then
                                echo "EAR/WAR/JAR Location found: ${earFileCopyTo}/${earFileName}"
                        fi

                        if test ${buildPath}/${logFileName}; then
                                echo "Log File Location found: ${buildPath}/${logFileName}"
                        fi

                        if test ${earFileCopyTo}/${checkSumFileName}; then
                                echo "checksum File Location found : ${earFileCopyTo}/${checkSumFileName}"
                        fi

                        ant -v -lib /apps/builds/ramclient/ramclient-ant.jar -file /apps/builds/ramclient/ramPublishAssetCdrive.xml -Dram.asset.version="${projectversion}" -Dram.asset.category="${ramcategory}" -Dram.asset.name="${thisassetname}" -Dram.asset.community="Tapestry Develop" -Dram.asset.type="Package Components" -Dram.asset.tag="${generatedTag}" -Dram.asset.description="${thisassetname} Tapestry ${ramcategory} ${deployenv}" -Dram.asset.shortDescription="${thisassetname} Tapestry ${ramcategory} ${deployenv}" -Dram.asset.teamInfo="$emailid" -Dram.asset.artifacts="${earFileCopyTo}/${earFileName}" -Dram.asset.artifactschecksum="${earFileCopyTo}/${checkSumFileName}"  -Dram.asset.artifactsbuildlog="${buildPath}/${logFileName}" -Dram.asset.guid="1A056E17-E326-A8C5-B72A-39B48EBAE0B5"
                        STATUS=$?
                        if [ $STATUS -ne 0 ]; then
                         log "*** Uploading Artifacts to RAM (Rational Asset manager) FAILED *** FOR ${component}"
                         #delete_ws $repo_ws
                        # logout_rtc
                         usage "Error"
                        fi
                fi

                eMailsBody="TO: ${emailid} # Stream: ${stream} # Component: ${component} # Workspace: ${repo_ws} # Rational Asset Manager : {https://rational.kp.org/ram} # Asset Name: ${thisassetname} # Community: Tapestry Develop  # File Name: ${earFileCopyTo}/${checkSumFileName} # Date ${DATE_STRING}"
                log "########################### DRF/IRF INFO #############################################################################"
                log "${eMailsBody}"
                log "########################### DRF/IRF INFO #############################################################################"

                cd $buildPath
                sendEmail "${emailid}" "AUTO-BUILD-SUCCESS-FOR-Component:${tempCom}" "$eMailsBody" "${logfile}"
                log "JOB completed successfully, email is sent....."

                log "cmd: rm ${earFileCopyTo}/${checkSumFileName}"
                rm -f "${earFileCopyTo}/${checkSumFileName}"
fi
#delete the backup files from ramClient
rm -f /tmp/com.ibm.ram.ant/${tempEARfilename}*.ear
rm -f /tmp/com.ibm.ram.ant/${tempEARfilename}*.jar

echo "Finished sucessfully"
