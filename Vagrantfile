Vagrant.configure("2") do |config|

  nodes = []
  nodes << 'gitlab.home.net'
  nodes << 'jenkins-master.home.net'
  nodes << 'system-of-record.home.net'

  #### Loading Puppet Master (Ubuntu)
  config.vm.define "puppet-master.home.net" do |v|
    v.vm.box = "landregistry/ubuntu"
	  v.ssh.forward_agent = true
    v.vm.hostname = "puppet-master.home.net"
    v.vm.network "private_network", :ip => "172.16.42.50"
	  v.vm.provision :shell, :path => 'provision-master.sh'
    v.vm.synced_folder ".vagrant_home", "/home/vagrant"
    v.vm.synced_folder ".aptget", "/var/cache/apt/archives/"

	  v.vm.provider :virtualbox do |vb|
		  vb.customize ['modifyvm', :id, '--memory', ENV['VM_MEMORY'] || 2048]
		  vb.customize ["modifyvm", :id, "--cpus", ENV['VM_CPUS'] || 4]
	  end
  end

  #### Loading nodes (CentOS)
  for i in 0..nodes.length - 1
    config.vm.define nodes[i] do |v|
      v.vm.box = "landregistry/centos-beta"
  	  v.ssh.forward_agent = true
      v.vm.network "private_network", :ip => "172.16.42." + (51 + i.to_i).to_s
      v.vm.synced_folder ".yum", "/var/cache/yum"

  	  v.vm.provision :shell, :path => 'provision-agent.sh'

  	  v.vm.provider :virtualbox do |vb|
  		  vb.customize ['modifyvm', :id, '--memory', ENV['VM_MEMORY'] || 2048]
  	  	vb.customize ["modifyvm", :id, "--cpus", ENV['VM_CPUS'] || 4]
  	  end
    end
  end

end
