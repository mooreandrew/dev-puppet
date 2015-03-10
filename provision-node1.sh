hostname puppet-master.home.net
echo puppet-master.home.net > /etc/hostname
echo 172.16.42.50 puppet-master.home.net >> /etc/hosts

sed -i -e 's,keepcache=0,keepcache=1,g' /etc/yum.conf

echo "https://docs.puppetlabs.com/references/3.6.latest/man/apply.html"

service network restart

sudo yum install -y http://yum.theforeman.org/releases/latest/el7/x86_64/foreman-release.rpm
sudo yum install -y http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm

git clone https://github.com/LandRegistry-Ops/puppet-control.git

cd puppet-control

yum install -y puppet

ln -s /usr/local/bin/librarian-puppet /usr/bin/librarian-puppet

gem install librarian-puppet

librarian-puppet install

puppet apply --modulepath=site:modules site/profiles/tests/puppet/master.pp

sed -i 's/production/development/' /etc/puppet/puppet.conf
