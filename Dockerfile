FROM ubuntu:16.04
LABEL maintainer "nasuno@ascade.co.jp"

RUN apt-get update \
  && apt-get -y install \
     supervisor \
     openssh-server \
     unzip \
     curl \
     tcpdump \
     traceroute \
     iptables xz-utils xfsprogs btrfs-tools \
     ruby-dev gcc g++ make \
  && echo 'gem: --no-document' >> /etc/gemrc \
  && gem install fluentd:0.12.33 fluent-plugin-cadvisor:0.3.1 \
  && apt-get -y remove make gcc g++ ruby-dev && apt-get -y autoremove

RUN groupadd --system dockremap \
  && useradd --system -g dockremap dockremap \
  && echo 'dockremap:165536:65536' >> /etc/subuid \
  && echo 'dockremap:165536:65536' >> /etc/subgid

# Docker in Docker <https://hub.docker.com/_/docker/>
ENV DOCKER_VERSION 1.13.1
RUN wget "https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz" -O docker.tgz \
  && tar xzf docker.tgz \
  && mv docker/* /usr/local/bin/ \
  && rmdir docker \
  && rm docker.tgz

RUN wget https://github.com/docker-library/docker/blob/50ec917e1b7601d655daee8893567e8cfd213248/1.13/docker-entrypoint.sh -O /usr/local/bin/docker-entrypoint.sh \
  && chmod +x /usr/local/bin/docker-entrypoint.sh

ENV DIND_COMMIT 3b5fac462d21ca164b3778647420016315289034
RUN wget "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind" -O /usr/local/bin/dind \
  && chmod +x /usr/local/bin/dind

RUN wget https://github.com/google/cadvisor/releases/download/v0.24.1/cadvisor -O /usr/local/bin/cadvisor \
  && chmod +x /usr/local/bin/cadvisor

RUN wget https://releases.hashicorp.com/serf/0.8.1/serf_0.8.1_linux_amd64.zip -O serf.zip \
  && unzip serf.zip -d /usr/local/bin/ \
  && rm serf.zip

RUN mkdir -p /var/run/sshd \
 && sed -i 's/^PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config \
 && sed -i 's/^Port 22/Port 10022/' /etc/ssh/sshd_config \
 && echo "root:root" | chpasswd
 
COPY supervisord.conf /etc/supervisor/conf.d/vcpbase.conf

CMD ["/usr/bin/supervisord"]
