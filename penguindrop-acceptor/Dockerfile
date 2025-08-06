FROM ubuntu:latest
EXPOSE 22

SHELL ["/bin/sh", "-c"]
WORKDIR /home/ubuntu
RUN apt-get update && \
    apt-get install -y openssh-server sudo && \
    mkdir /var/run/sshd && \
    echo 'ubuntu:target' | chpasswd && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

CMD ["/usr/sbin/sshd", "-D"]