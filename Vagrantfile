# -*- mode: ruby -*-
# vi: set ft=ruby :

#=========================================
# See README.md for more details
#=========================================


####################################
# basic config
####################################

_config = {
    "synced_folders" => {
        "/var/www" => "./www",
        "/home/vagrant/Projects" => "./Projects"
    },
    "ip_address" => "33.33.33.80",
    "nfs" => !!(RUBY_PLATFORM =~ /darwin/ || RUBY_PLATFORM =~ /linux/)
}
CONF = _config


####################################
# vagrantfile for LINDAT/CLARIN DSpace
####################################

# Actual Vagrant configs
Vagrant.configure("2") do |config|

    # if you do not know what it is - ignore
    if Vagrant.has_plugin?('vagrant-cachier')
       config.cache.auto_detect = true

       # set vagrant-cachier scope to :box, so other projects that share the
       # vagrant box will be able to used the same cached files
       config.cache.scope = :box

       # and lets specifically use the apt cache (note, this is a Debian-ism)
       config.cache.enable :apt

       # use the generic cache bucket for Maven
       config.cache.enable :generic, {
             "maven" => { cache_dir: "/root/.m2/repository" },
       }
    end

    # base box definition
    #
    config.vm.box_url = "http://files.vagrantup.com/precise64.box"
    config.ssh.forward_agent = true

    # set basic VM properties (in virtualbox provider!)
    #  
    config.vm.provider :virtualbox do |v|
        v.memory = 2048
        v.cpus = 1
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
    end

    # synced folders
    #   - one folder in guest/host machines e.g., Projects or www
    if CONF.has_key?('synced_folders')
        CONF['synced_folders'].each { |target, source|
          if source
            config.vm.synced_folder source, target, :nfs => CONF['nfs'], :create => true
          end
        }
    end

    # small tuning - utf8, bell off
    #
    config.vm.provision :shell, :inline => "locale | grep 'LANG=en_US.UTF-8' > /dev/null || sudo update-locale --reset LANG=en_US.UTF-8"
    config.vm.provision :shell, :inline => "grep '^set bell-style none' /etc/inputrc || echo 'set bell-style none' >> /etc/inputrc"

   
    #=================
    # set up LINDAT/CLARIN repository
    #
    config.vm.define "lindat", autostart: true do |lindat|
        lindat.vm.hostname = "dspace.lindat.dev"
        lindat.vm.network :private_network, ip: CONF['ip_address']
        lindat.vm.box = "precise64-lindat.dspace"
        lindat.vm.provider :virtualbox do |v|
            v.customize ["modifyvm", :id, "--name", "lindat-dspace-box"]
            v.cpus = 1
        end    
        
        # Shell script to set apt sources.list to something appropriate (close to you, and actually up) via apt-spy2
        #
        config.vm.provision :puppet do |puppet|
            puppet.manifests_path = "puppet/manifests"
            puppet.module_path = "puppet/modules"
            puppet.manifest_file  = "lindat.pp"
            puppet.facter = {
                "java_version"  => "8",
                "tom_version"   => "7",
                "repo_branch"   => "clarin-dev",
                "fqdn"          => "dspace.lindat.dev",
            }
            #puppet.options = ['--verbose']
            #puppet.options = ['--graph']
        end
    
        # set up our environment
        #
        lindat.vm.provision "shell", path: "./Projects/libs/setup.probe.sh"
        #lindat.vm.provision "shell", path: "./Projects/libs/setup.jenkins.sh"
        lindat.vm.provision "shell", path: "./Projects/libs/setup.munin.sh"
        lindat.vm.provision "shell", path: "./Projects/setup.lindat.sh"
        #lindat.vm.provision "shell", path: "./Projects/setup.lindat.piwik.sh"
        lindat.vm.provision "shell", path: "./Projects/setup.lindat.fill.with.data.sh"
    end

    #=================
    # set up DSpaceX repository
    #
    config.vm.define "dspace4", autostart: false do |dspace4|
        dspace4.vm.hostname = "dspace.dev"
        dspace4.vm.network :private_network, ip: "33.33.33.79"
        dspace4.vm.box = "precise64-dspace4.dspace"
        dspace4.vm.provider :virtualbox do |v|
            v.customize ["modifyvm", :id, "--name", "original-dspace-box"]
            v.customize ["modifyvm", :id, "--ioapic", "on"]
            v.cpus = 2
        end    
        
        # Shell script to set apt sources.list to something appropriate (close to you, and actually up) via apt-spy2
        #
        config.vm.provision :puppet do |puppet|
            puppet.manifests_path = "puppet/manifests"
            puppet.module_path = "puppet/modules"
            puppet.manifest_file  = "dspace.pp"
            puppet.facter = {
                "java_version" => "7",
                "tom_version"  => "7",
                "repo_branch"  => "dspace-4_x",
                "fqdn"         => "dspace.dev",
            }
            puppet.options = ['--verbose']
            #puppet.options = ['--graph']
        end
        
        # use args for other machines
        dspace4.vm.provision "shell", path: "./Projects/libs/setup.probe.sh"
        #dspace4.vm.provision "shell", path: "./Projects/libs/setup.jenkins.sh"
        dspace4.vm.provision "shell", path: "./Projects/libs/setup.munin.sh"
        dspace4.vm.provision "shell", path: "./Projects/setup.dspace.sh"
        
    end

    # Message to display to user after 'vagrant up' completes
    config.vm.post_up_message = "Setup of 'lindat repository' is now COMPLETE! Available services are listed at:\n\nhttp://#{CONF['ip_address']}"
    
end
