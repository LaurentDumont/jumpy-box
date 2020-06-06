FROM ubuntu:20.04

# Allow apt to work without any user input.
ENV DEBIAN_FRONTEND=noninteractive 

# Install ssh/python3/curl/pip
RUN apt-get update && apt-get install -y openssh-server python3 curl python3-pip
# Need to create this for SSH to work correctly - usually created by systemd.
RUN mkdir /var/run/sshd
# Add our jumpbox user
RUN adduser --shell /bin/bash --gecos 'Jumpy user' --disabled-password jumpy

# Install the openstack client + heat for the stack command
RUN pip3 install python-openstackclient python-heatclient

# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl; \
  chmod +x kubectl; \
  mv kubectl /usr/bin/kubectl

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

#ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Disable MOTD
#RUN sed -i 's/^ENABLED=.*/ENABLED=0/' /etc/default/motd-news

COPY .hushlogin /home/jumpy/.hushlogin

#RUN chmod -x /etc/update-motd.d/*
COPY motd.sh /etc/profile.d/motd.sh
COPY buff-unicorn /etc/profile.d/buff-unicorn
RUN chmod +x /etc/profile.d/motd.sh

COPY authorized_keys /home/jumpy/.ssh/

RUN chmod 0700 /home/jumpy/.ssh && chmod 0600 /home/jumpy/.ssh/authorized_keys
RUN chown jumpy:jumpy /home/jumpy/.ssh
RUN chown jumpy:jumpy /home/jumpy/.ssh/authorized_keys

#COPY sshd_config /etc/ssh/sshd_config

EXPOSE 22
CMD ["/usr/sbin/sshd", "-e","-D"]
