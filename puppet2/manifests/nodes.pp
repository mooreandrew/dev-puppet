# Set role based on hostname
if empty($machine_role) {
  $machine_role = regsubst($::hostname, '^(.*)-\d+$', '\1')
}
notify{"machine_role: ${$machine_role}": }



# Default nodes
node default {

  # Create 'lr-admin' group on all hosts
  group { 'lr-admin' :
    ensure => present,
    gid    => 2000
  }

  # Configure passwordless sudo for 'lr-admin' group
  sudo::conf { 'lr-admin' :
    priority => 20,
    content  => '%lr-admin  ALL=(ALL)  NOPASSWD: ALL',
  }

  # Create accounts from Hiera data
  create_resources( 'account', hiera_hash('accounts', {require => Group['lr-admin']}) )
}
