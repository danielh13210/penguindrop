FROM ubuntu:latest
EXPOSE 22

SHELL ["/bin/sh", "-c"]
WORKDIR /home/ubuntu
RUN apt-get update && \
    apt-get install -y openssh-server && \
    mkdir /var/run/sshd /home/ubuntu/.ssh && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

CMD ["/usr/sbin/sshd", "-D"]