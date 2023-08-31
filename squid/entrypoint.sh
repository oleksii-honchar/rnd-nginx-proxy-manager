#!/bin/sh
SQUID_ACCESS_LOG_FILE=/var/log/squid/squid_access_log_pipe
SQUID_CACHE_LOG_FILE=/var/log/squid/squid_cache_log_pipe

mkfifo $SQUID_ACCESS_LOG_FILE
mkfifo $SQUID_CACHE_LOG_FILE
chown -R squid:squid $SQUID_ACCESS_LOG_FILE
chown -R squid:squid $SQUID_CACHE_LOG_FILE

cat < $SQUID_ACCESS_LOG_FILE >/dev/stdout &
cat < $SQUID_CACHE_LOG_FILE >/dev/stdout &

exec "$@"