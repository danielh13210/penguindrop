FROM ubuntu:latest
EXPOSE 22

SHELL ["/bin/sh", "-c"]
WORKDIR /home/ubuntu
COPY ./sshd_config /etc/ssh/sshd_config
RUN apt-get update && \
    apt-get install -y openssh-server --no-install-recommends && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
RUN mkdir /var/run/sshd /home/ubuntu/.ssh && chown ubuntu:ubuntu /home/ubuntu/.ssh && chmod 700 /home/ubuntu/.ssh

CMD ["/usr/sbin/sshd", "-D"]
