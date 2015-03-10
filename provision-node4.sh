hostname system-of-record.home.net
echo system-of-record.home.net > /etc/hostname
echo 172.16.42.50 puppet-master.home.net >> /etc/hosts

sed -i -e 's,keepcache=0,keepcache=1,g' /etc/yum.conf

service network restart
sudo rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
sudo yum -y install puppet
sed -i 's/ssldir = $vardir\/ssl/ssldir = $vardir\/ssl\nserver = puppet-master.home.net\nlogdir = \/var\/log\/pe-puppet/' /etc/puppet/puppet.conf
sed -i 's/\[agent\]/\[agent\]\nenvironment = development/' /etc/puppet/puppet.conf

puppet agent --test

puppet resource cron puppet-agent ensure=present user=root minute=5 command='/usr/bin/puppet agent --onetime --no-daemonize --splay'
