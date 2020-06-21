#!/bin/bash
set -e

# Start proxy
exec /usr/local/cloud_sql_proxy -instances=mvp-api-254102:us-central1:mvp-api=tcp:5432 \
    -credential_file=/usr/local/ssh-master-account-key.json &

# Wait for proxy start
sleep 5 &&

    # Execute original command
    exec "$@"
