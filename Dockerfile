FROM ubuntu:16.04
MAINTAINER nasuno@ascade.co.jp

RUN apt-get update \
 && apt-get -y install \
    supervisor \
    openssh-server \
    curl \
    iptables xz-utils xfsprogs e2fsprogs btrfs-tools \
    ruby \
    ruby-dev gcc make \
 && echo 'gem: --no-document' >> /etc/gemrc \
 && gem install string-scrub -v 0.0.5 \
 && gem install fluentd -v 0.12.22 \
 && apt-get -y remove make gcc ruby-dev && apt-get -y autoremove

# Docker in Docker <https://hub.docker.com/_/docker/>
RUN curl -sSL https://get.docker.com/builds/Linux/x86_64/docker-1.10.3 > /usr/local/bin/docker \
 && curl -sSL https://raw.githubusercontent.com/docker/docker/3b5fac462d21ca164b3778647420016315289034/hack/dind > /usr/local/bin/dind \
 && curl -sSL https://raw.githubusercontent.com/docker-library/docker/83b2eab8bdb5d35bf343313154ab55938fca3807/1.10/dind/dockerd-entrypoint.sh > /usr/local/bin/dockerd-entrypoint.sh \
 && chmod +x /usr/local/bin/docker /usr/local/bin/dind

RUN curl -sSL https://releases.hashicorp.com/serf/0.7.0/serf_0.7.0_linux_amd64.zip > serf.zip \
 && unzip serf.zip -d /usr/local/bin/ \
 && rm serf.zip

RUN mkdir -p /var/run/sshd \
 && sed -i 's/^PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config \
 && sed -i 's/^Port 22/Port 10022/' /etc/ssh/sshd_config \
 && echo "root:root" | chpasswd

COPY supervisord.conf /etc/supervisor/conf.d/vcpbase.conf

CMD ["/usr/bin/supervisord"]

