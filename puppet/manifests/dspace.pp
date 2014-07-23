#
# part of LINDAT/CLARIN vagrant package (http://lindat.cz)
# see lindat.pp
#

group { 'puppet': 
    ensure => present 
}
Exec { 
    path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] 
}
File { 
    owner => 0, group => 0, mode => 0644 
}


# basic definitions
import "common"

# needed by dspace
postgresql::dbcreate { 'dspace':
    role => 'dspace',
    password => 'dspace',
}

# create the directories and AFTER (->) do the installation.
# The dspace puppet module comes from https://github.com/DSpace/vagrant-dspace
# but has been stripped down to a reusable (in a way) light script (see modules/dspace). 
#
file { ["/installations/", "/installations/dspace/"]:
    ensure => "directory",
    mode   => "0777",
}
->
dspace::install { "vagrant-dspace":
    owner               => "vagrant",
    require             => Class['tomcat'],

    # taken from Vagrantfile
    git_branch          => "${repo_branch}",

    # clone to this directory - could be put to Projects so it is transparent
    # with host OS but the compilation than took forever (40+minutes)
    # 
    src_dir             => "/home/vagrant/dspace-${repo_branch}-src",

    # this is where ant should be executed in but in (at least) 4_x branch it is
    # made of a version which can change so we are using a little hacking inside
    # the module
    #
    ant_installer_dir   => "/home/vagrant/dspace-${repo_branch}-src/dspace/target/dspace-*", 

    # must be the same as in vagrant.properties.erb!
    install_dir         => "/installations/dspace/dspace-orig-${repo_branch}",

    # indicate to use vagrant.properties for configuration 
    mvn_params          => '-Denv=vagrant',

    # login credentials
    admin_firstname     => 'Mr.',
    admin_lastname      => 'Demo',
    admin_email         => 'dspace@lindat.cz',
    admin_passwd        => 'dspace',
    #
    admin_language      => 'en',
} 