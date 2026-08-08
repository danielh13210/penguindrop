FROM ubuntu:latest
EXPOSE 22

SHELL ["/bin/sh", "-c"]
WORKDIR /home/ubuntu
RUN apt-get update && \
    apt-get install -y openssh-server --no-install-recommends && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/ssh/ssh_host_*_key*
COPY ./sshd_config /etc/ssh/sshd_config
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN mkdir /var/run/sshd /home/ubuntu/.ssh && chown ubuntu:ubuntu /home/ubuntu/.ssh && chmod 700 /home/ubuntu/.ssh && chown root:root /etc/ssh/sshd_config /docker-entrypoint.sh

CMD ["/docker-entrypoint.sh"]
