hostname puppet-master.home.net
echo puppet-master.home.net > /etc/hostname
echo 172.16.42.50 puppet-master >> /etc/hosts

sudo rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
sudo yum -y install puppet-server
sudo yum -y install puppet

setenforce 0

yum install -y ruby-devel
yum install -y zlib-devel openssl-devel
#gem install thin
#ln -s /usr/local/bin/thin /usr/bin/thin
#cd /usr/share/puppet/ext/rack/
#thin -p 8140 --ssl --ssl-key-file /var/lib/puppet/ssl/private_keys/puppet-master.home.net.pem --ssl-cert-file /var/lib/puppet/ssl/certs/puppet-master.home.net.pem -d start

yum groupinstall -y 'development tools'

yum install -y curl-devel
gem install passenger
#passenger-install-nginx-module

ln -s /usr/local/bin/passenger-install-nginx-module /usr/bin/passenger-install-nginx-module


passenger-install-nginx-module --auto

( cmdpid=$BASHPID; (sleep 5; kill $cmdpid) & puppet master --no-daemonize --verbose )

#puppet module install jfryman-nginx

cat << EOF > /etc/puppet/manifests/site.pp

class { 'nginx':  }

nginx::resource::vhost { 'puppet':
  ensure               => present,
  server_name          => ['puppet'],
  listen_port          => 8140,
  ssl                  => true,
  ssl_cert             => '/var/lib/puppet/ssl/certs/puppet-master.home.net.pem',
  ssl_key              => '/var/lib/puppet/ssl/private_keys/puppet-master.home.net.pem',
  ssl_port             => 8140,
  vhost_cfg_append     => {
    'passenger_enabled'      => 'on',
    'passenger_ruby'         => '/usr/bin/ruby',
    'ssl_crl'                => '/var/lib/puppet/ssl/ca/ca_crl.pem',
    'ssl_client_certificate' => '/var/lib/puppet/ssl/certs/ca.pem',
    'ssl_verify_client'      => 'optional',
    'ssl_verify_depth'       => 1,
  },
  www_root             => '/etc/puppet/rack/public',
  use_default_location => false,
  access_log           => '/var/log/nginx/puppet_access.log',
  error_log            => '/var/log/nginx/puppet_error.log',
  passenger_cgi_param  => {
    'HTTP_X_CLIENT_DN'     => '$ssl_client_s_dn',
    'HTTP_X_CLIENT_VERIFY' => '$ssl_client_verify',
  },
}

EOF

cd /etc/puppet
#puppet apply --modulepath=modules manifests/site.pp

mkdir /opt/nginx/conf/sites-enabled/
mkdir /opt/nginx/conf/sites-available/

cat << EOF > /opt/nginx/conf/sites-enabled/puppet.conf

server {
  listen                     8140 ssl;
  server_name                puppet puppetmaster.example.com;

  passenger_enabled          on;
  passenger_set_cgi_param    HTTP_X_CLIENT_DN $ssl_client_s_dn;
  passenger_set_cgi_param    HTTP_X_CLIENT_VERIFY $ssl_client_verify;

  access_log                 /var/log/nginx/puppet_access.log;
  error_log                  /var/log/nginx/puppet_error.log;

  root                       /etc/puppet/rack/public;

  ssl_certificate            /var/lib/puppet/ssl/certs/puppetmaster.home.net.home;
  ssl_certificate_key        /var/lib/puppet/ssl/private_keys/puppetmaster.example.net.pem;
  ssl_crl                    /var/lib/puppet/ssl/ca/ca_crl.pem;
  ssl_client_certificate     /var/lib/puppet/ssl/certs/ca.pem;
  ssl_ciphers                SSLv2:-LOW:-EXPORT:RC4+RSA;
  ssl_prefer_server_ciphers  on;
  ssl_verify_client          optional;
  ssl_verify_depth           1;
  ssl_session_cache          shared:SSL:128m;
  ssl_session_timeout        5m;
}


EOF

cat << EOF > /opt/nginx/conf/sites-available/puppet.conf

server {
  listen                     8140 ssl;
  server_name                puppet puppetmaster.example.com;

  passenger_enabled          on;
  passenger_set_cgi_param    HTTP_X_CLIENT_DN $ssl_client_s_dn;
  passenger_set_cgi_param    HTTP_X_CLIENT_VERIFY $ssl_client_verify;

  access_log                 /var/log/nginx/puppet_access.log;
  error_log                  /var/log/nginx/puppet_error.log;

  root                       /etc/puppet/rack/public;

  ssl_certificate            /var/lib/puppet/ssl/certs/puppetmaster.home.net.home;
  ssl_certificate_key        /var/lib/puppet/ssl/private_keys/puppetmaster.example.net.pem;
  ssl_crl                    /var/lib/puppet/ssl/ca/ca_crl.pem;
  ssl_client_certificate     /var/lib/puppet/ssl/certs/ca.pem;
  ssl_ciphers                SSLv2:-LOW:-EXPORT:RC4+RSA;
  ssl_prefer_server_ciphers  on;
  ssl_verify_client          optional;
  ssl_verify_depth           1;
  ssl_session_cache          shared:SSL:128m;
  ssl_session_timeout        5m;
}


EOF

sudo /opt/nginx/sbin/nginx

chown nginx:nginx /var/log/nginx/access.log
chown nginx:nginx /var/log/nginx/error.log


# https://github.com/phusion/passenger/wiki/Why-can't-Phusion-Passenger-extend-my-existing-Nginx%3F
#http://www.watters.ws/mediawiki/index.php/Configure_puppet_master_using_nginx_and_mod_passenger
