echo 172.16.42.50 puppet-master.home.net >> /etc/hosts

wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
sudo dpkg -i puppetlabs-release-trusty.deb
sudo apt-get update

sudo apt-get -y install git
sudo apt-get -y install ruby-dev

sudo apt-get -y install puppet

git clone https://github.com/LandRegistry-Ops/puppet-control.git
cd puppet-control
git pull

gem install librarian-puppet
ln -s /usr/local/bin/librarian-puppet /usr/bin/librarian-puppet

librarian-puppet install

puppet apply --modulepath=site:modules site/profiles/tests/puppet/master.pp
sed -i "s/environments    => 'directory',//" /home/vagrant/puppet-control/site/profiles/manifests/puppet/master.pp
sed -i "s/\$confdir/\/etc\/puppet/" /home/vagrant/puppet-control/site/profiles/manifests/puppet/master.pp

sudo cp /home/vagrant/puppet-control/site/profiles/files/hiera.yaml /etc/
sudo cp /home/vagrant/puppet-control/site/profiles/files/hiera.yaml /etc/puppet/

r10k deploy environment -p

service puppetmaster restart


sed -i 's/production/development/' /etc/puppet/puppet.conf
