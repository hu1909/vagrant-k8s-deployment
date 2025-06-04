require 'yaml'
require 'ipaddr'

config_data = YAML.load_file("configuration.yml")
start_ip = IPAddr.new(config_data["network"]["starting_ip"]).to_i

assigned_ips = {}
ip_counter = 0 
Vagrant.configure("2") do |config|
  # config.vm.provision "shell", inline: <<-SHELL
  #   echo "192.168.56.2 controlplane" >> /etc/hosts 
  #   cat /etc/hosts
  #   sudo systemctl restart systemd-resolved
  # SHELL
  config_data["machines"].each do |machine|
    config.vm.define machine["name"] do |node|
      hostname = machine["name"]
      node.vm.box = "bento/ubuntu-24.04" 
      node.vm.hostname = hostname
      ip = if machine["role"] == "control-plane"
        IPAddr.new(config_data["network"]["control_plane_ip"]).to_s
      else 
        loop do 
          next_ip = IPAddr.new(start_ip + ip_counter, Socket:: AF_INET)
          ip_counter += 1
          break next_ip.to_s unless assigned_ips.value?(next_ip.to_s)
        end 
      end 
    
      node.vm.network "private_network", ip: ip 

      assigned_ips[hostname] = ip 

      node.vm.provision "shell", inline: <<-SHELL
        echo "#{ip} #{hostname}" >> /etc/hosts
        sudo systemctl restart systemd-resolved 
      SHELL

      node.vm.provision "shell", path: "bash-script/common-installation.sh"
      node.vm.synced_folder "./bash-script/", "/vagrant-data-script/"

      if machine["role"] == "control-plane"
        node.vm.provision "shell", path: "bash-script/control-plane-node.sh"
        node.vm.synced_folder "./storage/controlplane-node/", "/vagrant-data/"
      else 
        node.vm.provision "shell", path: "bash-script/worker-node.sh"
        node.vm.synced_folder "./storage/worker-node/", "/vagrant-data/"
      end     

      node.vm.provider "virtualbox" do |vb|
        vb.memory = machine["role"] == "control-plane" ? 4096 : 2048
        vb.cpus = machine["role"] == "control-plane" ? 4 : 2
      end 
    end 

  # config.vm.define "controlplane" do |controlplane|
  #   controlplane.vm.hostname = "controlplane"
  #   controlplane.vm.box = "bento/ubuntu-24.04"
  #   controlplane.vm.box_check_update = true
  #   controlplane.vm.synced_folder "./bash-script/", "/vagrant-data-script/"
  #   controlplane.vm.synced_folder "./storage/controlplane-node/", "/vagrant-data/"
  #   controlplane.vm.network "private_network", ip: "192.168.56.2"
  #   controlplane.vm.provision "shell", path: "bash-script/common-installation.sh"
  #   controlplane.vm.provision "shell", path: "bash-script/control-plane-node.sh"
  #   controlplane.vm.provider "virtualbox" do |vb|
  #     vb.cpus = 2 
  #     vb.memory = "2048"
  #   end 

    # config.vm.define "workernode01" do |workernode|
    #   workernode.vm.hostname = "workernode01"
    #   workernode.vm.box = "bento/ubuntu-24.04"
    #   workernode.vm.box_check_update=true 
    #   workernode.vm.synced_folder "./bash-script/", "/vagrant-data-script/"
    #   workernode.vm.synced_folder "./storage/worker-node-01/", "/vagrant-data/"
    #   workernode.vm.network "private_network", ip: "192.168.56.10"
    #   workernode.vm.provision "shell", path: "bash-script/common-installation.sh"
    #   workernode.vm.provision "shell", path: "bash-script/worker-node.sh"
    # end


    # config.vm.define "ansible" do |jenkins|
    #   jenkins.vm.hostname = "ansible-server"
    #   jenkins.vm.box = "bento/ubuntu-24.04"
    #   jenkins.vm.box_check_update=true 
    #   jenkins.vm.provision "shell", inline: <<-SHELL 
    #     sudo apt-get update 
    #   SHELL
  end 
end
