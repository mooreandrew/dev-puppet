hostname puppet-master.home.net
echo puppet-master.home.net > /etc/hostname
echo 192.168.0.200 puppet-master.home.net >> /etc/hosts
echo 192.168.0.201 gitlab-app.home.net >> /etc/hosts

service network restart

sudo yum install -y http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
sudo yum install -y http://yum.theforeman.org/releases/latest/el7/x86_64/foreman-release.rpm

sudo yum -y install puppet
puppet module install stephenrjohnson-puppet
puppet module install zack-r10k

puppet apply -e "class{'puppet::repo::puppetlabs': } Class['puppet::repo::puppetlabs'] -> Package <| |> class { 'puppetdb': }  class { 'puppet::master': storeconfigs => true }"

# zack/r10k
puppet apply -e "
class { '::r10k':  configfile                => '/etc/puppet/r10k.yaml',  configfile_symlink        => '/etc/r10k.yaml',  manage_configfile_symlink => true,  manage_modulepath         => false,  sources                   => {    'control' => {      'remote'  => 'https://github.com/LandRegistry-Ops/puppet-control.git',      'basedir' => '/etc/puppet/environments',      'prefix'  => false    }  }}"

cat << EOF > /etc/hiera.yaml
:hierarchy:
  - secrets/nodes/%{::fqdn}
  - secrets/environments/%{environment}
  - secrets/secrets
  - roles/%{::machine_role}
  - common

:backends:
  - yaml

:yaml:
  :datadir: /etc/puppet/environments/%{environment}/hiera

EOF

ln -s /etc/hiera.yaml /etc/puppet/hiera.yaml

sed -i 's/ssldir = $vardir\/ssl/ssldir = $vardir\/ssl\nserver = puppet-master.home.net\nlogdir = \/var\/log\/pe-puppet\nenvironmentpath = $confdir\/environments\nbasemodulepath = $confdir\/modules:\/opt\/puppet\/share\/puppet\/modules/' /etc/puppet/puppet.conf
sed -i 's/modulepath = \/etc\/puppet\/modules//' /etc/puppet/puppet.conf
sed -i 's/manifest = \/etc\/puppet\/manifests\/site.pp//' /etc/puppet/puppet.conf
sed -i 's/\[agent\]/\[agent\]\nenvironment = development/' /etc/puppet/puppet.conf

ln -s /usr/local/bin/r10k /usr/bin/r10k
r10k deploy environment -p

puppet agent -t

sed -i "s/$external_url    = 'localhost',/$external_url    = 'http:\/\/localhost',/" /etc/puppet/environments/development/site/profiles/manifests/gitlab.pp
sed -i "s/Redhat     => 'nfs-utils',/Redhat     => 'nfs-utils',\nCentOS     => 'nfs-utils',/" /etc/puppet/environments/development/site/profiles/manifests/gitlab.pp
sed -i "s/){/){\n \$gitlab_download_link = \$::operatingsystem ? {\nCentOS     => 'https:\/\/downloads-packages.s3.amazonaws.com\/centos-7.0.1406\/gitlab-7.5.1_omnibus.5.2.0.ci-1.el7.x86_64.rpm',\nRedhat     => 'https:\/\/downloads-packages.s3.amazonaws.com\/centos-7.0.1406\/gitlab-7.5.1_omnibus.5.2.0.ci-1.el7.x86_64.rpm',\n    Ubuntu     => 'https:\/\/downloads-packages.s3.amazonaws.com\/ubuntu-14.04\/gitlab_7.5.1-omnibus.5.2.0.ci-1_amd64.deb',\n}/" /etc/puppet/environments/development/site/profiles/manifests/gitlab.pp
sed -i "s/'https:\/\/downloads-packages.s3.amazonaws.com\/ubuntu-14.04\/gitlab_7.5.1-omnibus.5.2.0.ci-1_amd64.deb'/\$gitlab_download_link/" /etc/puppet/environments/development/site/profiles/manifests/gitlab.pp

sed -i "s/  \$deploy_from_jenkins_rsa,/  \$deploy_from_jenkins_rsa = ''/" /etc/puppet/environments/development/site/profiles/manifests/jenkins.pp
