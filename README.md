LINDAT/CLARIN vagrant boxes
===========================

This project uses [vagrant](http://vagrantup.com) to create a temporary Virtual Machine (VM) (suitable for developers) provisioned by [puppet](http://puppetlabs.com/) (responsible for installation of additional software) with an installation of the repository developed at [LINDAT/CLARIN](http://lindat.cz) based on DSpace including a number of useful tools.
The VM can be created for different providers e.g., [VirtualBox](https://www.virtualbox.org/).

There is a similar project [vagrant-dspace](https://github.com/DSpace/vagrant-dspace) but we found it not suitable for our needs.  

Developed by
-------------

[LINDAT/CLARIN](http://lindat.cz) dev team (jm)


Requirements
------------

* vagrant
* virtualbox (tested) 


What can you expect (lindat box)
--------------------------------

After cloning this project and executing `vagrant up` (or better `vagrant up lindat`) you will get a VM with:

* Ubuntu 12.04 VM with `33.33.33.78` ip address and `dspace.lindat.dev` hostname (update your hosts file to reach it under this name)
* git, java, maven
* apache, tomcat
* [probe](https://code.google.com/p/psi-probe/), [nagios](http://www.nagios.org/), [munin](http://munin-monitoring.org/), [monit](http://mmonit.com/monit/), [phppgadmin](http://phppgadmin.sourceforge.net/doku.php)
* [jenkins](http://jenkins-ci.org/) with a simple reload script
* latest version of the LINDAT/CLARIN repository inside a _shared directory_ easily accessible between your computer the new VM (_Projects/..._ and _www_) 
* out-of-the-box availability to debug DSpace on port _8000_ using Remote debugging e.g., in Eclipse. Use the sources from the shared directory.
* overview Web page at http://33.33.33.78 or better (http://dspace.lindat.dev) containg also users and passwords to the services


BEWARE!!!
---------

The VM exposes many crucial interfaces with no or simple passwords - do not make the VM accessible from any external network!

Internals
---------

The project is a standard Vagrant + puppet. Vagrant resources are described in _Vagrantfile_ and contain definitions of two preconfigured boxes: `lindat` and `dspace4`. 

The below snippet shows several variables passed from Vagrant to puppet provisioner 

```
        puppet.facter = {
        "java_version"  => "7",
        "tom_version"   => "7",
        "repo_branch"   => "master-dev",
        "fqdn"          => "dspace.lindat.dev",
        }
```

which control java and tomcat version (tested also with java6 and tomcat6, for java8 read comments in puppet/manifests/lindat.pp). 
Puppet definitons and modules are in puppet directory with puppet/manifests/lindat.pp the main file being executed for the `lindat` box.

The puppet modules have been slightly modified to match our needs.

When puppet finishes Vagrant calls shell scripts e.g., 

```
        lindat.vm.provision "shell", path: "./Projects/libs/setup.probe.sh"
        lindat.vm.provision "shell", path: "./Projects/libs/setup.jenkins.sh"
        lindat.vm.provision "shell", path: "./Projects/libs/setup.munin.sh"
        lindat.vm.provision "shell", path: "./Projects/setup.lindat.sh" 
```

There are several reasons why they are not part of puppet (they could be in general).


Original DSpace
---------------

There is another box called `dspace4` which installs dspace4 in a very similar environment as our `lindat` box. A considerable stripped down and fixed version of the puppet module in [vagrant-dspace](https://github.com/DSpace/vagrant-dspace) was used. 

License
--------

This project is [CC-BY](http://creativecommons.org/licenses/by/2.0/) unless noted otherwise in the particular modules.


Big thanks goes to
------------------

[example42.com](http://example42.com) which created most of the puppet modules used in this project. 

