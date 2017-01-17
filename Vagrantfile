# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.provider "docker" do |d|
    d.image = "jschmidlapp/docker-esp8266:latest"
    d.has_ssh = true
  end

  config.ssh.port = 22
  
end
