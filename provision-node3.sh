hostname jenkins-master.home.net
echo jenkins-master.home.net > /etc/hostname
echo 192.168.0.200 puppet-master.home.net >> /etc/hosts
echo 192.168.0.201 gitlab-app.home.net >> /etc/hosts
echo 192.168.0.202 jenkins-master.home.net >> /etc/hosts

service network restart
sudo rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
sudo yum -y install puppet
sed -i 's/ssldir = $vardir\/ssl/ssldir = $vardir\/ssl\nserver = puppet-master.home.net\nlogdir = \/var\/log\/pe-puppet/' /etc/puppet/puppet.conf
sed -i 's/\[agent\]/\[agent\]\nenvironment = development/' /etc/puppet/puppet.conf

puppet agent --test

puppet resource cron puppet-agent ensure=present user=root minute=5 command='/usr/bin/puppet agent --onetime --no-daemonize --splay'
