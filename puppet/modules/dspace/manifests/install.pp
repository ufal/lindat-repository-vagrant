# Comes from https://github.com/DSpace/vagrant-dspace
# Hacked by LINDAT/CLARIN
# Definition: dspace::install
#
# Each time this is called, the following happens:
#  - DSpace source is pulled down from GitHub
#  - DSpace Maven build process is run (if it has not yet been run)
#  - DSpace Ant installation process is run (if it has not yet been run)
#
# Tested on:
# - Ubuntu 12.04
#
# Parameters:
# - $owner (REQUIRED)   => OS User who should own DSpace instance
# - $version (REQUIRED) => Version of DSpace to install (e.g. "3.0", "3.1", "4.0", etc)
# - $group              => Group who should own DSpace instance. Defaults to same as $owner
# - $src_dir            => Location where DSpace source should be kept (defaults to the home directory of $owner at ~/dspace-src)
# - $install_dir        => Location where DSpace instance should be installed (defaults to the home directory of $owner at ~/dspace)
# - $service_owner      => Owner of the actual DSpace service (i.e. Tomcat service). Defaults to same as $owner
# - $service_group      => Group of the actual DSpace service (i.e. Tomcat service). Defaults to same as $group
# - $git_repo           => Git repository to pull DSpace source from. Defaults to DSpace/DSpace in GitHub
# - $git_branch         => Git branch to build DSpace from. Defaults to "master".
# - $mvn_params         => Any build params passed to Maven. Defaults to "-Denv=vagrant" which tells Maven to use the vagrant.properties file.
# - $ant_installer_dir  => Full path of directory where the Ant installer is built to (via Maven).
# - $admin_firstname    => First Name of the created default DSpace Administrator account.
# - $admin_lastname     => Last Name of the created default DSpace Administrator account.
# - $admin_email        => Email of the created default DSpace Administrator account.
# - $admin_passwd       => Initial Password of the created default DSpace Administrator account.
# - $admin_language     => Language of the created default DSpace Administrator account.
# - $ensure => Whether to ensure DSpace instance is created ('present', default value) or deleted ('absent')
#
# Sample Usage:
# dspace::install {
#    owner      => "vagrant",
#    version    => "4.0-SNAPSHOT",
#    git_branch => "master",
# }
#
define dspace::install ($owner,
                        $group             = $owner,
                        $src_dir           = "/home/${owner}/Projects/dspace-src", 
                        $install_dir       = "/home/${owner}/dspace",
                        $service_owner     = $owner, 
                        $service_group     = $owner,
                        $ant_installer_dir = "$src_dir/dspace/target/dspace-installer",
                        $git_repo          = 'https://github.com/DSpace/DSpace.git',
                        $git_branch        = 'master',
                        $mvn_params        = '-Denv=vagrant',
                        $admin_firstname   = 'DSpaceDemo',
                        $admin_lastname    = 'Admin',
                        $admin_email       = 'dspacedemo+admin@gmail.com',
                        $admin_passwd      = 'vagrant',
                        $admin_language    = 'en',
                        $ensure            = present)

{

    # ensure that the install_dir exists, and has proper permissions
    file { "${install_dir}":
        ensure => "directory",
        owner  => $service_owner,
        group  => $service_group,
        mode   => 0700,
    }

->

    # Clone DSpace GitHub to ~/dspace-src
    exec { "git clone ${git_repo} ${src_dir}":
        command   => "git clone ${git_repo} ${src_dir}; chown -R ${owner}:${group} ${src_dir}",
        creates   => $src_dir,
        logoutput => true,
        tries     => 2, # try 2 times, with a ten minute timeout, GitHub is sometimes slow, if it's too slow, might as well get everything else done
        timeout   => 0,
    }

->

    # Checkout the specified branch
    exec { "Checkout branch ${git_branch}" :
       command => "git checkout ${git_branch}",
       cwd     => $src_dir, # run command from this directory
       user    => $owner,
       # Only perform this checkout if the branch EXISTS and it is NOT currently checked out (if checked out it will have '*' next to it in the branch listing)
       onlyif  => "git branch -a | grep -w '${git_branch}' && git branch | grep '^\\*' | grep -v '^\\* ${git_branch}\$'",
    }

->

   # Create a 'vagrant.properties' file which will be used to build the DSpace installer
   # (INSTEAD OF the default 'build.properties' file that DSpace normally uses)
   file { "${src_dir}/vagrant.properties":
     ensure  => file,
     owner   => $owner,
     group   => $group,
     mode    => 0644,
     backup  => ".puppet-bak",  # If replaced, backup old settings to .puppet-bak
     content => template("dspace/vagrant.properties.erb"),
   }

->

   # Build DSpace installer.
   # (NOTE: by default, $mvn_params='-Denv=vagrant', which tells Maven to use the vagrant.properties file created above)
   exec { "Build DSpace installer in ${src_dir}":
     command   => "mvn package ${mvn_params}",
     cwd       => "${src_dir}", # Run command from this directory
     user      => $owner,
     timeout   => 0, # Disable timeout. This build takes a while!
     logoutput => true,	# Send stdout to puppet log file (if any)
   }

->

   # Install DSpace (via Ant)
   exec { "Install DSpace to ${install_dir}":
     command    => "bash -c \"cd $ant_installer_dir && ant fresh_install\"",
     cwd        => "/home",
     user       => $owner,
     path       => ["/bin/", "/usr/bin", "/usr/sbin"], 
     logoutput  => true,	# Send stdout to puppet log file (if any)
   } 

->

   # create administrator
   exec { "Create DSpace Administrator":
     command   => "${install_dir}/bin/dspace create-administrator -e ${admin_email} -f ${admin_firstname} -l ${admin_lastname} -p ${admin_passwd} -c ${admin_language}",
     cwd       => $install_dir,
     user      => $owner,
     logoutput => true,
   }

}
