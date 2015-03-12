echo 172.16.42.50 puppet-master.home.net >> /etc/hosts

wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
sudo dpkg -i puppetlabs-release-trusty.deb
sudo apt-get update

sudo apt-get -y install puppet

git clone https://github.com/LandRegistry-Ops/puppet-control.git
cd puppet-control
git pull

gem install librarian-puppet
ln -s /usr/local/bin/librarian-puppet /usr/bin/librarian-puppet

librarian-puppet install

puppet apply --modulepath=site:modules site/profiles/tests/puppet/master.pp

sed -i 's/production/development/' /etc/puppet/puppet.conf
