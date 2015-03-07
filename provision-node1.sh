hostname puppet-master.home.net
echo puppet-master.home.net > /etc/hostname
echo 192.168.0.200 puppet-master.home.net >> /etc/hosts
echo 192.168.0.201 gitlab-app.home.net >> /etc/hosts
echo 192.168.0.202 jenkins-master.home.net >> /etc/hosts

service network restart

sudo rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
sudo yum -y install puppet-server
sudo service puppetmaster start
#sed -i 's/ssldir = $vardir\/ssl/ssldir = $vardir\/ssl\nserver = puppet-master.home.net\nlogdir = \/var\/log\/pe-puppet/' /etc/puppet/puppet.conf

puppet module install rtyler-jenkins
puppet module install cornfeedhobo-nano
puppet module install puppetlabs-stdlib
puppet module install spuder-gitlab

puppet resource cron puppet-agent ensure=present user=root minute=5 command='/usr/bin/puppet agent --onetime --no-daemonize --splay'

puppet agent --test; exit 0