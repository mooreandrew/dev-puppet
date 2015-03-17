require 'yaml'

if (!File.exist?('servers.yaml')) then
  File.open('servers.yaml', 'w') { |file| file.write("#Variables:\n#  name = Server Name, this should match to the hiera profile\n#  environment = The enviornment the node should use when connecting to puppet - Default is set to development\n#  clone = If r10k needs to be updated (If you need to pick up changes commits to github) - Set to false to speed up deployment.\n#  ip = The ip address of the local machine\n#\n# Duplicate the nodes line to add another sever\n\nservers:\n  - gitlab-app.home.net:\n      environment: development\n      clone: true\n      ip: 172.16.42.51\n  - jenkins-master.home.net:\n      environment: development\n      clone: true\n      ip: 172.16.42.52\n") }
end

servers = YAML.load_file('servers.yaml')

$nodes = []

servers['servers'].each do |key |
  array = {}
  array['name'] = key.first[0]
  array['environment'] = key[key.first[0]]['environment']
  array['clone'] = key[key.first[0]]['clone']
  array['ip'] = key[key.first[0]]['ip']
  $nodes << array
end

Vagrant.configure("2") do |config|

  #### Loading Puppet Master (Ubuntu)
  config.vm.define "puppet-master.home.net" do |v|
    v.vm.box = "ubuntu/trusty64"
	  v.ssh.forward_agent = true
    v.vm.hostname = "puppet-master.home.net"
    v.vm.network "private_network", :ip => "172.16.42.50"
	  v.vm.provision :shell, :path => 'provision-master.sh'
    v.vm.synced_folder ".aptget", "/var/cache/apt/archives/"
    v.vm.synced_folder ".home", "/home/vagrant/"

    v.vm.synced_folder ".environments", "/etc/puppet/environments"

	  v.vm.provider :virtualbox do |vb|
		  vb.customize ['modifyvm', :id, '--memory', ENV['VM_MEMORY'] || 2048]
		  vb.customize ["modifyvm", :id, "--cpus", ENV['VM_CPUS'] || 4]
	  end
  end

  #### Loading nodes (CentOS)
  (0..($nodes.length - 1)).each do |i|
    config.vm.define $nodes[i]['name'] do |v|
      v.vm.box = "landregistry/centos-beta"
  	  v.ssh.forward_agent = true
      v.vm.network "private_network", :ip => $nodes[i]['ip']
      v.vm.synced_folder ".yum", "/var/cache/yum"
      v.vm.host_name = $nodes[i]['name']
  	  v.vm.provision :shell, :path => 'provision-agent.sh', :args => $nodes[i]['environment'] + " " + $nodes[i]['clone'].to_s

  	  v.vm.provider :virtualbox do |vb|
  		  vb.customize ['modifyvm', :id, '--memory', ENV['VM_MEMORY'] || 2048]
  	  	vb.customize ["modifyvm", :id, "--cpus", ENV['VM_CPUS'] || 4]
  	  end
    end
  end

end
