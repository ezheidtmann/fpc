#
# Squishymedia's DRCOG Vagrantfile
#

# GETTING STARTED
#
# Get your vm set up:
#   vagrant up
# Set up hosts file on your local machine:
#   127.0.0.1 drcog.local btw.local wtg.local
# Sync the database:
#   vagrant ssh
#   cd /vagrant/htdocs
#   drush sql-sync @btw-dev @btw-local
# Sync uploaded files:
#   drush rsync @btw-dev:%files @btw-local:%files
#
# Visit the site at http://btw.local:3080/

# ------------------------------------

boxes = [
  { :name => 'web', :role => :web },
]

hostname = %x[ hostname ]
username = %x[ whoami ]

Vagrant::Config.run do |config|
  vm_default = proc do |cnf|
    #cnf.vm.box_url = "http://files.vagrantup.com/precise64.box"
	cnf.vm.box_url = "http://bastion.squishyclients.net/precise64_squishy_2013-02-09.box"
	cnf.vm.box = "precise64_squishy_2013-02-09"
    cnf.vm.customize ["modifyvm", :id, "--memory", 1024]

    # attempt to fix "read-only filesystem" errors in Mac OS X
    # see: https://github.com/mitchellh/vagrant/issues/713
    cnf.vm.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
    cnf.vm.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/server", "1"]
	# NFS mount needs hostonly net
	config.vm.network :hostonly, "10.11.12.13"
    # Mount webroot
    #cnf.vm.share_folder "server", "/server", ".", :owner => "www-data", :group => "www-data"
    cnf.vm.share_folder "server", "/server", ".", :nfs => true
    # Enable to launch a VirtualBox console
    #cnf.vm.boot_mode = :gui
  end

  boxes.each do |opts|
    config.vm.define opts[:name] do |config|
      vm_default.call(config)

      config.vm.host_name = "%s.%s.%s" % [ opts[:name], "drcog".to_s, hostname.strip.to_s ]

      config.vm.provision :shell, :path => 'vagrant/packages.sh'
      config.vm.provision :shell, :path => 'vagrant/setup.sh', :args => username
      config.vm.provision :shell, :path => 'vagrant/run.sh'

      config.vm.forward_port 80,   4080
      config.vm.forward_port 3306, 4006
    end
  end
end
