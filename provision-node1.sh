hostname puppetmaster
echo puppetmaster > /etc/hostname
echo 192.168.0.200 puppetmaster >> /etc/hosts
echo 192.168.0.201 repos >> /etc/hosts
echo 192.168.0.202 ci >> /etc/hosts

service network restart

sudo rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
sudo yum -y install puppet-server
sudo service puppetmaster start
sed -i 's/ssldir = $vardir\/ssl/ssldir = $vardir\/ssl\nserver = puppetmaster\nlogdir = \/var\/log\/pe-puppet/' /etc/puppet/puppet.conf

puppet module install rtyler-jenkins
puppet module install cornfeedhobo-nano
puppet module install puppetlabs-stdlib
puppet module install puppetlabs-apache
puppet module install spuder-gitlab

cat << EOF > /etc/puppet/manifests/site.pp

node basenode {
  include nano
}

node 'ci' inherits basenode {
   include jenkins
}

node 'repos' inherits basenode {
   class { gitlab : gitlab_branch => '7.3.0', external_url => 'http://192.168.0.201', }
}

node 'puppetmaster' inherits basenode {
   
}

EOF

puppet resource cron puppet-agent ensure=present user=root minute=5 command='/usr/bin/puppet agent --onetime --no-daemonize --splay'

puppet agent --test; exit 0