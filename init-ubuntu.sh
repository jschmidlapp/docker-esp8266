#!/bin/sh

sudo apt-get update
sudo apt-get install docker.io vagrant

sudo gpasswd -a ${USER} docker
sudo service docker restart
