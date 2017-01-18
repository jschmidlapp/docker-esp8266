FROM ubuntu:14.04
MAINTAINER Jason Schmidlapp <jason.schmidlapp@gmail.com>

RUN sed 's@archive.ubuntu.com@mirrors.digitalocean.com@' -i /etc/apt/sources.list

#update apt sources
RUN apt-get update --fix-missing

#install required packages
RUN apt-get install -y sudo git build-essential autoconf gperf bison flex texinfo wget help2man gawk libtool libncurses5-dev unzip libexpat-dev python2.7-dev python-serial unzip libexpat-dev

# Create and configure vagrant user
RUN useradd --create-home -s /bin/bash vagrant
WORKDIR /home/vagrant

RUN git clone https://github.com/tommie/esptool-ck.git \
    && cd esptool-ck \
    && make \
    && cp esptool /usr/bin

RUN rm -rf /opt \
    && git clone --recursive https://github.com/pfalcon/esp-open-sdk.git /opt \
    && usermod -a -G dialout vagrant \
    && echo "vagrant ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vagrant \
    && chmod 0440 /etc/sudoers.d/vagrant \
    && chown -R vagrant /opt \
    && chgrp -R vagrant /opt \
    && cd /opt \
    && su vagrant -c "make" \
    && rm -rf $(ls /opt/ | grep -v xtensa-lx106-elf)

#install required packages
RUN apt-get install -y apt-utils openssh-server nfs-common curl wget

# Configure SSH access
RUN mkdir -p /home/vagrant/.ssh && \
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" > /home/vagrant/.ssh/authorized_keys && \
    chown -R vagrant: /home/vagrant/.ssh && \
    adduser vagrant sudo && \
    `# Enable passwordless sudo for users under the "sudo" group` && \
    sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers && \
    echo -n 'vagrant:vagrant' | chpasswd && \
    `# Thanks to http://docs.docker.io/en/latest/examples/running_ssh_service/` && \
    mkdir /var/run/sshd

RUN apt-get clean

RUN echo "PATH=/opt/xtensa-lx106-elf/bin:\$PATH" >> /home/vagrant/.profile

# Expose port 22 for ssh
EXPOSE 22

# Leave the SHH daemon and container running
CMD /usr/sbin/sshd -D

