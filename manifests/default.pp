group { 'puppet': ensure => present }
Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }
File { owner => 0, group => 0, mode => 0644 }

class {'apt':
  always_apt_update => true,
}

Class['::apt::update'] -> Package <|
    title != 'python-software-properties'
and title != 'software-properties-common'
|>

    apt::key { '4F4EA0AAE5267A6C': }

apt::ppa { 'ppa:ondrej/php5':
  require => Apt::Key['4F4EA0AAE5267A6C']
}

class { 'puphpet::dotfiles': }

package { [
    'build-essential',
    'vim',
    'curl',
    'git-core',
    'linux-headers-`uname -r`'
    # ,
    # 'ffmpeg',
    # 'webmin'
  ]:
  ensure  => 'installed',
}

class { 'apache': }

apache::dotconf { 'custom':
  content => 'EnableSendfile Off',
}

apache::module { 'rewrite': }
apache::module { 'cache': }
apache::module { 'expires': }
apache::module { 'headers': }
apache::module { 'include': }
apache::module { 'mime_magic': }
apache::module { 'proxy_http': }
apache::module { 'proxy': }
apache::module { 'ssl': }
apache::module { 'vhost_alias': }

apache::vhost { 'kjp.local.host':
  server_name   => 'kjp.local.host',
  serveraliases => [
    'localhost'
  ],
  docroot       => '/var/www/',
  port          => '80',
  env_variables => [
],
  priority      => '1',
}
apache::vhost { 'elder-statesman.com.host':
  server_name   => 'elder-statesman.com.host',
  serveraliases => [
],
  docroot       => '/var/www/elder-statesman.com/deploy/',
  port          => '80',
  env_variables => [
],
  priority      => '1',
}
apache::vhost { 'hermes-pitch.host':
  server_name   => 'hermes-pitch.host',
  serveraliases => [
],
  docroot       => '/var/www/hermes-pitch/deploy/',
  port          => '80',
  env_variables => [
],
  priority      => '1',
}
apache::vhost { 'jbrandjeans.com.host':
  server_name   => 'jbrandjeans.com.host',
  serveraliases => [
],
  docroot       => '/var/www/jbrandjeans.com/deploy/',
  port          => '80',
  env_variables => [
],
  priority      => '1',
}
apache::vhost { 'lindex.com.host':
  server_name   => 'lindex.com.host',
  serveraliases => [
],
  docroot       => '/var/www/lindex.com/deploy/',
  port          => '80',
  env_variables => [
],
  priority      => '1',
}
apache::vhost { 'saturday-group.com.host':
  server_name   => 'saturday-group.com.host',
  serveraliases => [
],
  docroot       => '/var/www/saturday-group.com/deploy/',
  port          => '80',
  env_variables => [
],
  priority      => '1',
}
apache::vhost { 'itb-worldwide.com.host':
  server_name   => 'itb-worldwide.com.host',
  serveraliases => [
],
  docroot       => '/var/www/itb-worldwide.com/deploy/public_html/',
  port          => '80',
  env_variables => [
],
  priority      => '1',
}
apache::vhost { 'swarovskigroup.com.host':
  server_name   => 'swarovskigroup.com.host',
  serveraliases => [
],
  docroot       => '/var/www/swarovskigroup.com/deploy/distribution/',
  port          => '80',
  env_variables => [
],
  priority      => '1',
}
apache::vhost { 'swarovskigroup-holding.com.host':
  server_name   => 'swarovskigroup-holding.com.host',
  serveraliases => [
],
  docroot       => '/var/www/swarovski-holding/',
  port          => '80',
  env_variables => [
],
  priority      => '1',
}
apache::vhost { 'wednesdayagency.com.host':
  server_name   => 'wednesdayagency.com.host',
  serveraliases => [
],
  docroot       => '/var/www/wednesdayagency.com/deploy/',
  port          => '80',
  env_variables => [
],
  priority      => '1',
}

class { 'php':
  service             => 'apache',
  service_autorestart => false,
  module_prefix       => '',
}

php::module { 'php5-mysql': }
php::module { 'php5-cli': }
php::module { 'php5-curl': }
# php::module { 'php5-ffmpeg': }
php::module { 'php5-gd': }
php::module { 'php5-imagick': }
php::module { 'php5-intl': }
php::module { 'php5-mcrypt': }
php::module { 'php5-xmlrpc': }

class { 'php::devel':
  require => Class['php'],
}

class { 'php::pear':
  require => Class['php'],
}



$xhprofPath = '/var/www/xhprof'

php::pecl::module { 'xhprof':
  use_package     => false,
  preferred_state => 'beta',
}

if !defined(Package['git-core']) {
  package { 'git-core' : }
}

vcsrepo { $xhprofPath:
  ensure   => present,
  provider => git,
  source   => 'https://github.com/facebook/xhprof.git',
  require  => Package['git-core']
}

file { "${xhprofPath}/xhprof_html":
  ensure  => 'directory',
  owner   => 'vagrant',
  group   => 'vagrant',
  mode    => '0775',
  require => Vcsrepo[$xhprofPath]
}

composer::run { 'xhprof-composer-run':
  path    => $xhprofPath,
  require => [
    Class['composer'],
    File["${xhprofPath}/xhprof_html"]
  ]
}

apache::vhost { 'xhprof':
  server_name => 'xhprof',
  docroot     => "${xhprofPath}/xhprof_html",
  port        => 80,
  priority    => '1',
  require     => [
    Php::Pecl::Module['xhprof'],
    File["${xhprofPath}/xhprof_html"]
  ]
}


class { 'xdebug':
  service => 'apache',
}

class { 'composer':
  require => Package['php5', 'curl'],
}

puphpet::ini { 'xdebug':
  value   => [
    'xdebug.default_enable = 1',
    'xdebug.remote_autostart = 0',
    'xdebug.remote_connect_back = 1',
    'xdebug.remote_enable = 1',
    'xdebug.remote_handler = "dbgp"',
    'xdebug.remote_port = 9000'
  ],
  ini     => '/etc/php5/conf.d/zzz_xdebug.ini',
  notify  => Service['apache'],
  require => Class['php'],
}

puphpet::ini { 'php':
  value   => [
    'date.timezone = "Europe/London"'
  ],
  ini     => '/etc/php5/conf.d/zzz_php.ini',
  notify  => Service['apache'],
  require => Class['php'],
}

puphpet::ini { 'custom':
  value   => [
    'display_errors = On',
    'error_reporting = -1'
  ],
  ini     => '/etc/php5/conf.d/zzz_custom.ini',
  notify  => Service['apache'],
  require => Class['php'],
}


class { 'mysql::server':
  config_hash   => { 'root_password' => 'wednesday' }
}

mysql::db { 'wednesdayagency.com':
  grant    => [
    'ALL'
  ],
  user     => 'wednesdayagency',
  password => 'Allfather',
  host     => 'localhost',
  sql      => '/var/www/sql/wednesdayagency.com.sql',
  charset  => 'utf8',
  require  => Class['mysql::server'],
}
mysql::db { 'saturday-group.com':
  grant    => [
    'ALL'
  ],
  user     => 'saturday-group',
  password => 'Cronus',
  host     => 'localhost',
  sql      => '/var/www/sql/saturday-group.com.sql',
  charset  => 'utf8',
  require  => Class['mysql::server'],
}


