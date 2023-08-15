# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

SUBNET="192.168.128"
DOMAIN="hrm.local"

MONGONAME="mongoteminal"
MONGODESKTOPIP="#{SUBNET}.2"


#Generate a host file to share
$hostfiledata="127.0.0.1 localhost\n#{MONGODESKTOPIP} #{MONGONAME}.#{DOMAIN} #{MONGONAME}"

$set_host_file="cat <<EOF > /etc/hosts\n"+$hostfiledata+"\nEOF\n"

Vagrant.configure VAGRANTFILE_API_VERSION do |config|
  config.vm.box_download_insecure = true
  config.vm.synced_folder "C:\\", "/home/vagrant/C"
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 1
  end

  #Maquina con terminal
  config.vm.define :mongoteminal do |pm|
  pm.vm.boot_timeout = 1200
  config.vm.box = "ubuntu/xenial64"
  # pm.ssh.insert_key = false
  pm.vm.hostname = "#{MONGONAME}.#{DOMAIN}"
  pm.vm.network :private_network, ip: "#{MONGODESKTOPIP}" 
  pm.vm.network :forwarded_port, guest: 27017, host: 27017
  pm.vm.provision :shell, :inline => $set_host_file
	pm.vm.provision :shell, :path => "shell/bootstrap.sh"
  # config.vm.provision "shell", inline: <<-SHELL
  # cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
  # SHELL
  pm.vm.provision "file", source: "shell/instalar-mongodb_old.sh", destination: "/home/vagrant/shell/instalar-mongodb_old.sh"
  pm.vm.provision "file", source: "shell/instalar-mongodb.sh", destination: "/home/vagrant/shell/instalar-mongodb.sh"
  pm.vm.provision "file", source: "files/config.ini", destination: "/home/vagrant/shell/config.ini"
	# pm.vm.provision :shell, :inline => "sh shell/instalar-mongodb.sh -u ubuntumongodb -p secret -n 27017"
  pm.vm.network :forwarded_port, guest: 22, host: 30, id: "ssh", auto_correct: true
  end
end
