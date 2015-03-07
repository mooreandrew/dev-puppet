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


sed -i 's/ssldir = $vardir\/ssl/ssldir = $vardir\/ssl\nserver = puppet-master.home.net\nlogdir = \/var\/log\/pe-puppet\nmodulepath = $confdir\/environments\/$environment\/modules:$confdir\/environments\/$environment\/\n[master]\nmanifest = $confdir\/environments\/$environment\/site\/manifests\/site.pp/' /etc/puppet/puppet.conf
echo "environment = bugfix_missing_pkgs" >> /etc/puppet/puppet.conf

sudo service puppetmaster start

urlgrabber -o /etc/yum.repos.d/timhughes-r10k-epel-6.repo https://copr.fedoraproject.org/coprs/timhughes/r10k/repo/epel-6/timhughes-r10k-epel-6.repo
yum -y install rubygem-r10k
 
puppet module install rtyler-jenkins
puppet module install cornfeedhobo-nano
puppet module install puppetlabs-stdlib
puppet module install spuder-gitlab

ln -s /usr/local/bin/r10k /usr/bin/r10k
r10k deploy environment -p

puppet resource cron puppet-agent ensure=present user=root minute=5 command='/usr/bin/puppet agent --onetime --no-daemonize --splay'

puppet agent --test; exit 0