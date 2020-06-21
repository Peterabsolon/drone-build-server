#!/bin/bash
set -e

python /usr/local/service_account_ssh.py \
    --cmd "docker container stop mvp-app && docker container rm mvp-app && docker run -p 8080:8080 -d --name mvp-app peterabsolon/mvp-app:$DRONE_BUILD_NUMBER" \
    --account ssh-master-account@mvp-api-254102.iam.gserviceaccount.com \
    --project mvp-api-254102 --hostname $HOSTNAME
