Vagrant.configure("2") do |config|

  config.vm.define "node1" do |v|
    v.vm.box = "chef/centos-7.0"
	v.ssh.forward_agent = true
	v.vm.network "public_network", :ip => "192.168.0.200"
	
    v.vm.host_name = "node1"
	v.vm.provision :shell, :path => 'provision-node1.sh'
	v.vm.provider :virtualbox do |vb|
		vb.customize ['modifyvm', :id, '--memory', ENV['VM_MEMORY'] || 2048]
		vb.customize ["modifyvm", :id, "--cpus", ENV['VM_CPUS'] || 4]
	end
  end
  
  config.vm.define "node2" do |v|
      v.vm.box = "chef/centos-7.0"
	v.ssh.forward_agent = true
	v.vm.network "public_network", :ip => "192.168.0.201"
    v.vm.host_name = "node2"
	v.vm.provision :shell, :path => 'provision-node2.sh'
	v.vm.provider :virtualbox do |vb|
		vb.customize ['modifyvm', :id, '--memory', ENV['VM_MEMORY'] || 2048]
		vb.customize ["modifyvm", :id, "--cpus", ENV['VM_CPUS'] || 4]
	end
  end
  
  config.vm.define "node3" do |v|
      v.vm.box = "chef/centos-7.0"
	v.ssh.forward_agent = true
	v.vm.network "public_network", :ip => "192.168.0.202"
    v.vm.host_name = "node3"
	v.vm.provision :shell, :path => 'provision-node3.sh'
	v.vm.provider :virtualbox do |vb|
		vb.customize ['modifyvm', :id, '--memory', ENV['VM_MEMORY'] || 2048]
		vb.customize ["modifyvm", :id, "--cpus", ENV['VM_CPUS'] || 4]
	end
  end

end