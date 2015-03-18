echo 172.16.42.50 puppet-master.home.net puppet >> /etc/hosts

environment=$1
r10k=$2

sudo setenforce 0

sed -i -e 's,keepcache=0,keepcache=1,g' /etc/yum.conf

sudo yum -y install puppet
sudo yum -y install sshpass

sudo sed -i 's/\[agent\]/\[agent\]\nserver = puppet-master.home.net/' /etc/puppet/puppet.conf
sudo sed -i "s/\[agent\]/\[agent\]\nenvironment = $environment/" /etc/puppet/puppet.conf

sshpass -p vagrant ssh -t vagrant@puppet-master.home.net -o StrictHostKeyChecking=no "sudo puppet plugin download --environment $environment; sudo service puppetmaster restart; exit 0"

sshpass -p vagrant ssh -t vagrant@puppet-master.home.net -o StrictHostKeyChecking=no "sudo puppet cert clean $HOSTNAME; exit 0"

if [ $r10k = "true" ]; then
  sshpass -p vagrant ssh -t vagrant@puppet-master.home.net -o StrictHostKeyChecking=no "sudo r10k deploy environment -p; sudo mkdir /etc/puppet/environments/production; exit 0"
fi

puppet agent --test

echo "Exit Code: $?"
# Exit Code: 2 = there were changes (Success)
# Exit Code: 4 = there were failures during the transaction (Failure)
# Exit Code: 4 = there were both changes and failures (Failure)
