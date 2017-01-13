#
# part of LINDAT/CLARIN vagrant package (http://lindat.cz)
#
# The installation is done here
# apt, apt updated, different packages, php, apache, tomcat, perl, 
# java,
# nagios, munin, monit,
# postgresql, phppgadmin
#
# Thanks to http://example42.com/ 
#

class {'apt':
  always_apt_update => true,
  purge_sources_list => true,
}

Class['::apt::update'] -> Package <|
    title != 'python-software-properties'
and title != 'software-properties-common'
|>


apt::key { '4F4EA0AAE5267A6C': }

#apt::ppa { 'ppa:ondrej/php5-oldstable':
#  require => Apt::Key['4F4EA0AAE5267A6C']
#}

apt::conf{ 'ubuntu':
    ensure => present,
    priority => '01',
    content => "APT::Default-Release \"precise\";\n",
}

apt::source {'precise':
    ensure => present,
    location => "mirror://mirrors.ubuntu.com/mirrors.txt",
    release => 'precise',
    repos => 'main restricted universe multiverse',
}

apt::source {'precise-updates':
    ensure => present,
    location => "mirror://mirrors.ubuntu.com/mirrors.txt",
    release => 'precise-updates',
    repos => 'main restricted universe multiverse',
}

apt::source {'precise-backports':
    ensure => present,
    location => "mirror://mirrors.ubuntu.com/mirrors.txt",
    release => 'precise-backports',
    repos => 'main restricted universe multiverse',
}

apt::source {'precise-security':
    ensure => present,
    location => "mirror://mirrors.ubuntu.com/mirrors.txt",
    release => 'precise-security',
    repos => 'main restricted universe multiverse',
}

apt::source {'wily':
    ensure => present,
    location => "mirror://mirrors.ubuntu.com/mirrors.txt",
    release => 'wily',
    repos => 'main restricted universe multiverse',
}

apt::source {'openjdk-r-ppa-precise':
    ensure => present,
    location => 'http://ppa.launchpad.net/openjdk-r/ppa/ubuntu',
    release => 'precise',
    key => 'eb9b1d8886f44e2a',
    repos => 'main',
}

apt::source {'git-core-ppa-precise':
    ensure => present,
    location => 'http://ppa.launchpad.net/git-core/ppa/ubuntu',
    release => 'precise',
    key => 'E1DF1F24',
    repos => 'main',
}

apt::pin { 'tomcat8_wily':
	packages => '*tomcat8* libecj-java libservlet3.0-java',
	release => 'wily',
	priority => "1006",
}

file { '/home/vagrant/.bash_aliases':
  ensure => 'present',
  source => 'puppet:///modules/puphpet/dot/.bash_aliases',
}

file_line { 'env_editor':
   path => '/home/vagrant/.bashrc',
   line => 'export EDITOR=vim;',
}
file_line { 'env_maven':
   path => '/home/vagrant/.bashrc',
   line => 'export MAVEN_OPTS="-Xms512M -XX:MaxPermSize=2048M -Xmx2048M"',
}
file_line { 'env_our_tom':
   path => '/home/vagrant/.bashrc',
   line => "export TOM_VERSION=${tom_version}",
}
file_line { 'env_our_java':
   path => '/home/vagrant/.bashrc',
   line => "export JAVA_VERSION=${java_version};export JAVA_HOME=/usr/lib/jvm/java-1.${java_version}.0-openjdk-${architecture}/",
}
file_line { 'env_our_repo':
   path => '/home/vagrant/.bashrc',
   line => "export REPO_BRANCH=${repo_branch}",
}
file_line { 'java-home-environment':
   path => '/etc/environment',
   line => "JAVA_HOME=/usr/lib/jvm/java-1.${java_version}.0-openjdk-${architecture}/",
   match => 'JAVA_HOME',
}

exec { 'remove-default-java-link':
    path => '/usr/bin:/usr/sbin:/bin:/sbin',
    command => "rm -f /usr/lib/jvm/default-java",
    before => Class['tomcat'],
    require => Package['java'],
}

# synch with the above!
# does not work with sudo! but for all users
$common_vars = "
    export JAVA_HOME=/usr/lib/jvm/java-1.${java_version}.0-openjdk-${architecture}/
    # from common.pp in lindat vagrant
    export EDITOR=vim
    export MAVEN_OPTS=\"-Xms512M -XX:MaxPermSize=2048M -Xmx2048M -Dassembly.ignorePermissions=true\"
    export TOM_VERSION=${tom_version}
    export JAVA_VERSION=${java_version}
    export REPO_BRANCH=${repo_branch}
"

file { "/etc/profile.d/common.sh":
    content => "$common_vars"
}

file { '/home/vagrant/.vimrc':
  ensure => 'present',
  source => 'puppet:///modules/puphpet/dot/.vimrc',
}

package { [
    'build-essential',
    'vim',
    'curl',
    'git-core',
    'unzip',
    'htop',
    'iotop',
    'links',
    'libxml-xpath-perl',
    'mc',
    'ant',
    'maven',
  ]:
  ensure  => 'installed',
}

class { 'scripts': 
}

class { 'timezone':
  timezone => 'Europe/Prague',
}

class { 'perl': 
}


#
#
#

class { 'munin': 
    server_local    => true,
    address         => '*',
    #config_file_server => 'puppet:///modules/munin/munin.conf', 
}
exec { "sudo apt-get install -q -y postgresql-server-dev-9.1 --force-yes":
    cwd     => "/home/vagrant",
    path    => ["/usr/bin", "/usr/sbin"],
    require  => Package["munin"],
}
perl::cpan::module { 'DBD::Pg':
  ensure => present,
}

class { 'monit': 
    source => 'puppet:///modules/monit/monitrc',
    config_file_mode => 0664,
}

munin::plugin { 'postgres':
}

class { 'nagios':
    # dspace
    nagiosadmin_password => '$apr1$ThgE1lGm$xwYzfdXTVVDW046KC8H3./',
}

#
# storeconfigs should be set in order to allow more monitor_tools
#  but this is quite difficult
#

class { 'apache': 
    monitor      => true,
    monitor_tool => [ "monit" ],
}
apache::module { 'rewrite': 
}
apache::module { 'proxy': 
}
apache::module { 'proxy_http': 
}
apache::module { 'proxy_ajp': 
}

apache::vhost { 'default':
  template     => 'apache/virtualhost/my_vhost.conf.erb',
  server_admin => 'vagrant@localhost',
  port         => '80',
  priority     => '',
  docroot      => '/var/www',
  directory    => '/var/www',
  directory_allow_override   => 'All',
  directory_options => 'Indexes FollowSymLinks MultiViews',
}

class { 'php':
  service       => 'apache',
  module_prefix => '',
  require       => Package['apache'],
}
 
class { 'composer':
  require => Package['php5', 'curl'],
} 


#
#
#
class { "java":
    jdk => true,
    version => $java_version,
    require => apt::source['openjdk-r-ppa-precise'],
}

# used from dspace
#
exec { "Update alternatives to Java ${jdk_version}":
    command => "update-java-alternatives --set java-1.${java_version}.0-openjdk-${architecture}",
    unless  => "test \$(readlink /etc/alternatives/java) = '/usr/lib/jvm/java-${java_version}-openjdk-${architecture}/jre/bin/java'",
    require => [Package["java"], Package["maven"]],
    path    => "/usr/bin:/usr/sbin:/bin",
} 



#
#
#

class { "tomcat":
    require => [ Class["java"], apt::source['wily'] ],
}

# this one needs manual restart
tomcat::users  { 'users':
    source => 'puppet:///modules/tomcat/tomcat-users.xml',
    filemode => '0664',
}

## set debugging and more memory 
file { "/etc/default/tomcat${tom_version}":
    ensure => 'present',
    source => "puppet:///modules/tomcat/tomcat${tom_version}",
    mode   => '0664',
    notify => Class['tomcat'],
}
#
## set init.d script 
#file { "/etc/init.d/tomcat${tom_version}":
#    ensure => 'present',
#    source => "puppet:///modules/tomcat/init_tomcat${tom_version}",
#    replace => "yes",
#    mode   => '0755',
#    require => Class['tomcat'],
#}



#
#
#

class { 'postgresql':
    monitor      => true,
    monitor_tool => [ "monit" ],
}

postgresql::role { 'dspace':
    password => 'dspace',
    require  => Package["postgresql"]
}

postgresql::hba { 'hba':
  type => 'local',
  database => 'all',
  user => 'all',
  method => 'md5', 
}

postgresql::hba { 'hba-local':
  type => 'local',
  database => 'all',
  user => 'all',
  method => 'md5', 
}
postgresql::hba { 'hba-host':
  type => 'host',
  database => 'all',
  user => 'all',
  address => '127.0.0.1/32',
  method => 'md5', 
}

class {'phppgadmin':
    require  => Package["postgresql"]
}

# ensure we allow acces from everybody
file { '/etc/phppgadmin/apache.conf':
    ensure => 'present',
    source => 'puppet:///modules/phppgadmin/apache.conf',
    mode   => '0664',
    notify => Class['apache'],
    require  => Package["phppgadmin"],
}


#
#
file { '/etc/munin/apache.conf':
    ensure => 'present',
    source => 'puppet:///modules/munin/apache.conf',
    mode   => '0664',
    notify => Class['apache'],
    require  => Package["munin"],
}


#
#

class { 'sudo':
    config_file_replace => false, 
}
