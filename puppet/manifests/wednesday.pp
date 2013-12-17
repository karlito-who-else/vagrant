## Begin Server manifest

if $server_values == undef {
  $server_values = hiera('server', false)
}

# Ensure the time is accurate, reducing the possibilities of apt repositories
# failing for invalid certificates
include '::ntp'

group { 'puppet': ensure => present }
group { 'www-data': ensure => present }

class { 'apache':
  php_admin_value  => 'open_basedir none'
}