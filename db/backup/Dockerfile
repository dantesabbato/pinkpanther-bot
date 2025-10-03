FROM postgres:15
RUN apt-get update && apt-get install -y cron
RUN mkdir -p /backup
WORKDIR /backup
COPY run.sh restore.sh cron.sh /backup/
RUN chmod +x /backup/*.sh
CMD ["/backup/cron.sh", "&&", "tail", "-f", "/dev/null"]