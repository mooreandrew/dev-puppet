echo 172.16.42.50 puppet-master.home.net >> /etc/hosts
echo 172.16.42.50 puppet >> /etc/hosts

sed -i -e 's,keepcache=0,keepcache=1,g' /etc/yum.conf

sudo rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
sudo yum -y install puppet
sudo yum -y install sshpass

sudo sed -i 's/\[agent\]/\[agent\]\nserver = puppet-master.home.net/' /etc/puppet/puppet.conf

sudo sed -i 's/\[agent\]/\[agent\]\nenvironment = development/' /etc/puppet/puppet.conf

sshpass -p vagrant ssh -t vagrant@puppet-master.home.net -o StrictHostKeyChecking=no "sudo puppet cert clean $HOSTNAME; exit 0"
sshpass -p vagrant ssh -t vagrant@puppet-master.home.net -o StrictHostKeyChecking=no "sudo r10k deploy environment -p; exit 0"

puppet agent --test

puppet resource cron puppet-agent ensure=present user=root minute=5 command='/usr/bin/puppet agent --onetime --no-daemonize --splay'
