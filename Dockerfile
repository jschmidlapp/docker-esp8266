FROM ubuntu:14.04

MAINTAINER Jason Schmidlapp jason.schmidlapp@gmail.com

# Based on image from Huang Rui vowstar@gmail.com

ENV PATH=/opt/xtensa-lx106-elf/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin COMPILE=gcc

ENV HOME /root

# enable ssh
RUN rm -f /etc/service/sshd/down



RUN DEBIAN_FRONTEND=noninteractive apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq \
        git \
        autoconf \
        build-essential \
        gperf \
        bison \
        flex \
        texinfo \
        libtool \
        libncurses5-dev \
        wget \
        apt-utils \
        gawk \
        sudo \
        unzip \
        libexpat-dev \
        help2man \
        python2.7 \
        python2.7-dev \
        python-serial \
	openssh-server \
    && rm -rf /opt \
    && git clone --recursive https://github.com/pfalcon/esp-open-sdk.git /opt \
    && useradd -M -s /bin/bash -u 1000 build \
    && usermod -a -G dialout build \
    && echo "build ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/build \
    && chmod 0440 /etc/sudoers.d/build \
    && chown -R build /opt \
    && chgrp -R build /opt \
    && cd /opt \
    && su build -c "make STANDALONE=n" \
    && rm -rf $(ls /opt/ | grep -v xtensa-lx106-elf) \
    && DEBIAN_FRONTEND=noninteractive apt-get purge -yq \
        git \
        autoconf \
        build-essential \
        gperf \
        bison \
        flex \
        texinfo \
        libtool \
        libncurses5-dev \
        wget \
        apt-utils \
        gawk \
        unzip \
        libexpat-dev \
        help2man \
        python2.7-dev \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq \
        make \
    && DEBIAN_FRONTEND=noninteractive apt-get autoremove -yq --purge \
    && DEBIAN_FRONTEND=noninteractive apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && export release=`lsb_release -cs` \

RUN wget http://apt.puppetlabs.com/puppetlabs-release-$release.deb -O puppetlabs-release-$release.deb \
    && dpkg -i puppetlabs-release-$release.deb \
    && apt-get update \
    && apt-get install puppet -y

EXPOSE 22

RUN mkdir -p /var/run/sshd
RUN chmod 0755 /var/run/sshd

# Create and configure vagrant user
RUN useradd --create-home -s /bin/bash vagrant
WORKDIR /home/vagrant

# Configure SSH access
RUN mkdir -p /home/vagrant/.ssh
RUN echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" > /home/vagrant/.ssh/authorized_keys
RUN chown -R vagrant: /home/vagrant/.ssh
RUN echo -n 'vagrant:vagrant' | chpasswd

# Enable passwordless sudo for the "vagrant" user
RUN mkdir -p /etc/sudoers.d
RUN install -b -m 0440 /dev/null /etc/sudoers.d/vagrant
RUN echo 'vagrant ALL=NOPASSWD: ALL' >> /etc/sudoers.d/vagrant

# Clean up APT when done.

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*