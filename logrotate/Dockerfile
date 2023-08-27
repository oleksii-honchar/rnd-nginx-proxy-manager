FROM arm64v8/alpine
RUN apk add --no-cache logrotate busybox-openrc
CMD [ "crond", "-f", "-l", "8" ]
#CMD ["sh", "-c", "while true; do logrotate -f /etc/logrotate.conf -v; sleep 86400; done"]