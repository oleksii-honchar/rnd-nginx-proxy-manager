#!/bin/bash
# https://github.com/Supervisor/supervisor/issues/553
# Refer: https://stackoverflow.com/questions/26032541/how-to-get-system-time-in-nano-seconds-in-perl

# Prefix outputs with Time Stamp and Process Name
exec 1> >(while IFS= read -r line; do echo "$(date +"%Y-%m-%d %H:%M:%S,%3N") '${SUPERVISOR_PROCESS_NAME}' $line"; done >&1)
exec 2> >(while IFS= read -r line; do echo "$(date +"%Y-%m-%d %H:%M:%S,%3N") '${SUPERVISOR_PROCESS_NAME}' $line"; done >&2)

exec "$@"