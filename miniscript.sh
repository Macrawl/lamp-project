#!/bin/bash

#assign variables
file="vagrantfile"

#create a directory where the script will be executed
mkdir -p ~/deploy/master

#CD to the directory you created
cd ~/deploy/master

#initalize vagrant to pull a vagrantfile
vagrant init ubuntu/trusty64

#check if vagrantfile exist
if [ -f "$file" ]; then
 echo "$file exist"
#delete the last line of the file and edit the file
 sed -i '$ d' vagrantfile
else
 echo "$file does not exist"
#initiate file again
 vagrant init ubuntu/trusty64
fi

#EDIT THE VAGRANT FILE TO ADD MASTER AND SLAVE

#configure virtualbox
cat << EOL >> $file

config.vm.provider "virtualbox" do |vb|
 vb.memory = "1024"
 vb.cpus = "2"
end
EOL

#multi-machine setup
#setup master Node
cat << EOL >> $file
config.vm.define "master"  do |master|
    master.vm.box = "ubuntu/trusty64"
    master.vm.hostname = "master"
    master.vm.network  "private_network", type: "dhcp"
end
EOL

#setup slave Node

cat << EOL >> $file
config.vm.define "slave" do |slave|
    slave.vm.box = "ubuntu/trusty64"
    slave.vm.hostname = "slave"
    slave.vm.network "private_network", type: "dhcp"
end

EOL

#provisioning script
cat << EOL >> $file
#installing DNS to allow interactivity between machines

config.vm.provision "shell", inline: <<-SHELL
 sudo apt update && sudo apt upgrade -y
 sudo apt-get install -y avahi-daemon libnss-mdns
SHELL
end
EOL

#bring up the machines
vagrant up

#create a user 'altschool and grant root priveleges
vagrant ssh master -c "sudo useradd -m -G root altschool

#generate ssh key for master node
vagrant ssh master -c "ssh-keygen -t rsa -b 2048 -f /home/altschool/.ssh/id_rsa -N ''"

#copy public key to the slave node
vagrant ssh master -c "ssh-copy-id altschool@slave"

#create a directory on the master node
vagrant ssh master -c "sudo mkdir -p ~/mnt/altschool"

#write text in a file and send to the directory
vagrant ssh master -c "echo "text transfer to slave node" | sudo tee /mnt/altschool/test.txt"

#transfer to slave node
vagrant ssh master -c "sudo scp -r /mnt/altschool altschool@slave:/mnt/altschool"

#display running process on the master node
vagrant ssh master -cls"

#lamp stack deployment

#update packagge list
sudo apt-get update

#install apache server
sudo apt-get install apache2 -y

#enable apache to start on boot
sudo systemctl enable apache2

#start apache
sudo systemctl start apache2

#install mysql server
sudo apt-get install mysql-server -y

#secure mysql installation
sudo mysql_secure_installation <<EOF

EOF

#create mysql user and password
mysql_root_pass="rawl"
mysql_usr="Rahleigh"
mysql_pass ="rawl"

#create mysql user

sudo mysql -u root -p"$mysql_root_pass" <<MYSQL_SCRIPT
CREATE DATABASE mydb;
CREATE USER '$mysql_usr'@'localhost' IDENTIFIED BY '$mysql_pass';
GRANT ALL PRIVILEGES ON mydb.* TO '$mysql_usr'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

#install php
sudo apt-get install php libapache2-mod-php php-mysql -y

#create a test php file
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php

#restart apache to apply changes
sudo systemctl restart apache2
EOL

#run script on master and slave node
vagrant ssh master -c '/deploy/master/miniscript.sh'
vagrant ssh slave -c '/deploy/master/miniscript.sh'

chmod +x /deploy/master/miniscript.sh
