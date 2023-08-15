# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

SUBNET="192.168.128"
DOMAIN="1002f.local"

APACHEPHPNAME="apachephphost"
APACHEPHPNAMEIP="#{SUBNET}.2"


#Generate a host file to share
$hostfiledata="127.0.0.1 localhost\n#{APACHEPHPNAME} #{APACHEPHPNAME}.#{DOMAIN} #{APACHEPHPNAME}"

$set_host_file="cat <<EOF > /etc/hosts\n"+$hostfiledata+"\nEOF\n"

Vagrant.configure VAGRANTFILE_API_VERSION do |config|
  config.vm.box_download_insecure = true
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 1
  end

  #Maquina apache
  config.vm.define :apachephphost do |pm|
  pm.vm.boot_timeout = 1200
  config.vm.box = "bento/ubuntu-22.04"
  pm.vm.hostname = "#{APACHEPHPNAME}.#{DOMAIN}"
  pm.vm.network :private_network, ip: "#{APACHEPHPNAMEIP}" 
  pm.vm.network :forwarded_port, guest: 80, host: 8080
  pm.vm.provision :shell, :inline => $set_host_file
  pm.vm.provision "file", source: "files/phpinfo.php", destination: "/tmp/php/phpinfo.php"
  pm.vm.provision "file", source: "files/actividad_grupal.php", destination: "/tmp/php/actividad_grupal.php"
	pm.vm.provision :shell, :path => "shell/instalar-apache-php.sh"
  pm.vm.network :forwarded_port, guest: 22, host: 40, id: "ssh", auto_correct: true
  end
end
