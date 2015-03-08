hostname puppet-master.home.net
echo puppet-master.home.net > /etc/hostname
echo 192.168.0.200 puppet-master.home.net >> /etc/hosts
echo 192.168.0.201 gitlab-app.home.net >> /etc/hosts
echo 192.168.0.202 jenkins-master.home.net >> /etc/hosts

service network restart

sudo yum install -y git
sudo rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
sudo yum -y install puppet-server
gem install r10k


cat << EOF > /etc/r10k.yaml
---
:cachedir: /var/cache/r10k
:sources:
  :local:
    remote: https://github.com/LandRegistry-Ops/puppet-control
    basedir: /etc/puppet/environments


EOF

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

ln -s /etc/r10k.yaml /etc/puppet/r10k.yaml
ln -s /etc/hiera.yaml /etc/puppet/hiera.yaml

sed -i 's/ssldir = $vardir\/ssl/ssldir = $vardir\/ssl\nserver = puppet-master.home.net\nlogdir = \/var\/log\/pe-puppet\nenvironmentpath = $confdir\/environments\nbasemodulepath = $confdir\/modules:\/opt\/puppet\/share\/puppet\/modules/' /etc/puppet/puppet.conf
echo "environment = bugfix_missing_pkgs" >> /etc/puppet/puppet.conf

sudo service puppetmaster start

urlgrabber -o /etc/yum.repos.d/timhughes-r10k-epel-6.repo https://copr.fedoraproject.org/coprs/timhughes/r10k/repo/epel-6/timhughes-r10k-epel-6.repo
yum -y install rubygem-r10k

ln -s /usr/local/bin/r10k /usr/bin/r10k
r10k deploy environment -p

puppet resource cron puppet-agent ensure=present user=root minute=5 command='/usr/bin/puppet agent --onetime --no-daemonize --splay'

puppet agent --test

sudo service puppetmaster start

sed -i "s/$external_url    = 'localhost',/$external_url    = 'http:\/\/localhost',/" /etc/puppet/environments/bugfix_missing_pkgs/site/profiles/manifests/gitlab.pp
sed -i "s/Redhat     => 'nfs-utils',/Redhat     => 'nfs-utils',\nCentOS     => 'nfs-utils',/" /etc/puppet/environments/bugfix_missing_pkgs/site/profiles/manifests/gitlab.pp
sed -i "s/){/){\n \$gitlab_download_link = \$::operatingsystem ? {\nCentOS     => 'https:\/\/downloads-packages.s3.amazonaws.com\/centos-7.0.1406\/gitlab-7.5.1_omnibus.5.2.0.ci-1.el7.x86_64.rpm',\nRedhat     => 'https:\/\/downloads-packages.s3.amazonaws.com\/centos-7.0.1406\/gitlab-7.5.1_omnibus.5.2.0.ci-1.el7.x86_64.rpm',\n    Ubuntu     => 'https:\/\/downloads-packages.s3.amazonaws.com\/ubuntu-14.04\/gitlab_7.5.1-omnibus.5.2.0.ci-1_amd64.deb',\n}/" /etc/puppet/environments/bugfix_missing_pkgs/site/profiles/manifests/gitlab.pp
sed -i "s/'https:\/\/downloads-packages.s3.amazonaws.com\/ubuntu-14.04\/gitlab_7.5.1-omnibus.5.2.0.ci-1_amd64.deb'/\$gitlab_download_link/" /etc/puppet/environments/bugfix_missing_pkgs/site/profiles/manifests/gitlab.pp

sed -i "s/  \$deploy_from_jenkins_rsa,/  \$deploy_from_jenkins_rsa = ''/" /etc/puppet/environments/bugfix_missing_pkgs/site/profiles/manifests/jenkins.pp

