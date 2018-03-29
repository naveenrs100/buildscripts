#!/bin/ksh
#Script to move Jenkins Backup directories into artifactory
set -vx

export ArtifacT=/apps/build/jfrog
host=`hostname -s`
cd /apps/build/Jenkins_backups
ls -al

for dir in * ; do
  if [[ -d "$dir" ]]; then
    tar -cvf BKP_${dir}.tar ${dir}

        $ArtifacT rt u --url https://artifactory-bluemix.kp.org/artifactory/ --apikey AKCp5ZkxbpPmw8q6RcKyo8Aqug7SqEVt4pWghBy5tKn7dyX9x1WAj1kJEgatjXCHkUB9DaMhu "BKP_(*).tar" kpcc-staging/backups/Jenkins/${host}/
        STATUS=$?
        if [ $STATUS -eq 0 ]; then
                rm -rf BKP*.tar
                rm -rf ${dir}
        fi
  fi;
done
