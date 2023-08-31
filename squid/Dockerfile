FROM arm64v8/alpine
RUN apk --no-cache add squid

ENV SQUID_LOGS_DIR="/var/log/squid"

RUN mkdir -p $SQUID_LOGS_DIR && \
    chown -R squid:squid $SQUID_LOGS_DIR && \
    chmod -R 755 $SQUID_LOGS_DIR

COPY ./squid/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3128

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["/usr/sbin/squid", "-NYCd 1"]