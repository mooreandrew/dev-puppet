Vagrant.configure("2") do |config|

  config.vm.define "node1" do |v|
    v.vm.box = "landregistry/centos-beta"
	  v.ssh.forward_agent = true
    v.vm.network "private_network", :ip => "172.16.42.50"
    v.vm.host_name = "node1"
	  v.vm.provision :shell, :path => 'provision-node1.sh'
    v.vm.synced_folder "environments", "/etc/puppet/environments/"
    v.vm.synced_folder "yum", "/var/cache/yum"

	  v.vm.provider :virtualbox do |vb|
		  vb.customize ['modifyvm', :id, '--memory', ENV['VM_MEMORY'] || 2048]
		  vb.customize ["modifyvm", :id, "--cpus", ENV['VM_CPUS'] || 4]
	  end
  end

  config.vm.define "node2" do |v|
    v.vm.box = "landregistry/centos-beta"
	  v.ssh.forward_agent = true
    v.vm.network "private_network", :ip => "172.16.42.51"
    v.vm.host_name = "node2"

    v.vm.synced_folder "yum", "/var/cache/yum"

	  v.vm.provision :shell, :path => 'provision-node2.sh'

	  v.vm.provider :virtualbox do |vb|
		  vb.customize ['modifyvm', :id, '--memory', ENV['VM_MEMORY'] || 2048]
	  	vb.customize ["modifyvm", :id, "--cpus", ENV['VM_CPUS'] || 4]
	  end
  end
=begin
  config.vm.define "node3" do |v|
    v.vm.box = "chef/centos-7.0"
	  v.ssh.forward_agent = true
    v.vm.network "private_network", :ip => "172.16.42.52"
    v.vm.host_name = "node3"
    v.vm.synced_folder "yum", "/var/cache/yum"


  	v.vm.provision :shell, :path => 'provision-node3.sh'

  	v.vm.provider :virtualbox do |vb|
		  vb.customize ['modifyvm', :id, '--memory', ENV['VM_MEMORY'] || 2048]
		  vb.customize ["modifyvm", :id, "--cpus", ENV['VM_CPUS'] || 4]
	  end
  end

  config.vm.define "node4" do |v|
    v.vm.box = "chef/centos-7.0"
    v.ssh.forward_agent = true
    v.vm.network "private_network", :ip => "172.16.42.53"
    v.vm.host_name = "node3"
    v.vm.synced_folder "yum", "/var/cache/yum"


    v.vm.provision :shell, :path => 'provision-node4.sh'

    v.vm.provider :virtualbox do |vb|
      vb.customize ['modifyvm', :id, '--memory', ENV['VM_MEMORY'] || 2048]
      vb.customize ["modifyvm", :id, "--cpus", ENV['VM_CPUS'] || 4]
    end
  end
=end

end
