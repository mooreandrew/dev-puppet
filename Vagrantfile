Vagrant.configure("2") do |config|

  nodes = []
  nodes << {"name"  => 'system-of-record.home.net', "ip" =>  "172.16.42.51"}
  nodes << {"name"  => 'jenkins-master.home.net', "ip" =>  "172.16.42.52"}
  nodes << {"name"  => 'gitlab-app.home.net', "ip" =>  "172.16.42.53"}

  #### Loading Puppet Master (Ubuntu)
  config.vm.define "puppet-master.home.net" do |v|
    v.vm.box = "ubuntu/trusty64"
	  v.ssh.forward_agent = true
    v.vm.hostname = "puppet-master.home.net"
    v.vm.network "private_network", :ip => "172.16.42.50"
	  v.vm.provision :shell, :path => 'provision-master.sh'
    v.vm.synced_folder ".aptget", "/var/cache/apt/archives/"
    v.vm.synced_folder ".environments", "/etc/puppet/environments"

	  v.vm.provider :virtualbox do |vb|
		  vb.customize ['modifyvm', :id, '--memory', ENV['VM_MEMORY'] || 2048]
		  vb.customize ["modifyvm", :id, "--cpus", ENV['VM_CPUS'] || 4]
	  end
  end

  #### Loading nodes (CentOS)
  (0..(nodes.length - 1)).each do |i|
    config.vm.define nodes[i]['name'] do |v|
      v.vm.box = "landregistry/centos-beta"
  	  v.ssh.forward_agent = true
      v.vm.network "private_network", :ip => nodes[i]['ip']
      v.vm.synced_folder ".yum", "/var/cache/yum"
      v.vm.host_name = nodes[i]['name']
  	  v.vm.provision :shell, :path => 'provision-agent.sh'

  	  v.vm.provider :virtualbox do |vb|
  		  vb.customize ['modifyvm', :id, '--memory', ENV['VM_MEMORY'] || 2048]
  	  	vb.customize ["modifyvm", :id, "--cpus", ENV['VM_CPUS'] || 4]
  	  end
    end
  end

end
