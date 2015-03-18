echo 172.16.42.50 puppet-master.home.net puppet >> /etc/hosts


wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
sudo dpkg -i puppetlabs-release-trusty.deb
sudo apt-get update

sudo apt-get -y install git
sudo apt-get -y install ruby-dev

sudo apt-get -y install puppet

git clone https://github.com/LandRegistry-Ops/puppet-control.git
cd puppet-control
git pull

gem install librarian-puppet --no-ri --no-rdoc --no-document
ln -s /usr/local/bin/librarian-puppet /usr/bin/librarian-puppet

librarian-puppet install

sed -i "s/\$confdir/\/etc\/puppet/" /home/vagrant/puppet-control/site/profiles/manifests/puppet/master.pp
puppet apply --modulepath=site:modules site/profiles/tests/puppet/master.pp

sudo cp /home/vagrant/puppet-control/site/profiles/files/hiera.yaml /etc/
sudo cp /home/vagrant/puppet-control/site/profiles/files/hiera.yaml /etc/puppet/

r10k deploy environment -p

sed -i 's/production/development/' /etc/puppet/puppet.conf

sleep 120

sudo service puppetmaster restart
service apache2 restart

echo "Fixing Package Issues"
sed -i "s/  \$deploy_from_jenkins_rsa,/  \$deploy_from_jenkins_rsa = ''/" /etc/puppet/environments/development/site/profiles/manifests/jenkins.pp
