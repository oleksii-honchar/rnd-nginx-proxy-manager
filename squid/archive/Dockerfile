FROM arm64v8/alpine
RUN apk --no-cache add squid busybox-openrc logrotate supervisor bash perl

ENV SQUID_LOGS_DIR="/var/log/squid"

RUN mkdir -p $SQUID_LOGS_DIR && \
    chown -R squid:squid $SQUID_LOGS_DIR && \
    chmod -R 755 $SQUID_LOGS_DIR

COPY ./squid/crontabs /etc/crontabs/root
#COPY ./squid/logrotate.conf /etc/logrotate.conf
#COPY ./squid/logrotate-squid.conf /etc/logrotate.d/logrotate-squid.conf

COPY ./squid/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY ./squid/cron-echo.sh /etc/cron-echo.sh
RUN chmod +x /etc/cron-echo.sh

COPY ./squid/prefix-log.sh /usr/local/bin/prefix-log
RUN chmod +x /usr/local/bin/prefix-log

COPY ./squid/supervisord.conf /etc/supervisor/supervisord.conf

EXPOSE 3128

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# squid -NYCd 1 : -N - stay in foreground, -Y - debug mode, -C - use config, -d 1 - lowest debug level
#CMD /usr/sbin/squid -NYCd 1
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]