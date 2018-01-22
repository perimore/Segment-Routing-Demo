# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

#Image Version of vEOS being used. Remember to create the corrisponding BOX in vagrant
image_version = "vEOS-lab-4.20.2F"
# List of Switches being instantiated in the enviroment
switches = {

    "bb1" => {
       :ssh_port => 2021,
       :eapi_port => 4041,
       :mgmt_ip => "192.168.100.11", # This is a dummy IP, it won't really configure Mgmt1, it is set to DHCP in the base box
       :connections => ["bb1-bb2", "bb1-bb3", "bb1-controller"]
    },
   "bb2" => {
       :ssh_port => 2022,
       :eapi_port => 4042,
       :mgmt_ip => "192.168.100.12",
       :connections => ["bb1-bb2", "bb2-bb3", "bb2-bb4", "bb2-bb5"]
   },
   "bb3" => {
       :ssh_port => 2023,
       :eapi_port => 4043,
       :mgmt_ip => "192.168.100.13",
       :connections => ["bb1-bb3", "bb2-bb3", "bb3-bb4", "bb3-bb5a", "bb3-bb5b"]
   },
   "bb4" => {
       :ssh_port => 2024,
       :eapi_port => 4044,
       :mgmt_ip => "192.168.100.14",
       :connections => ["bb2-bb4", "bb3-bb4", "bb4-bb5", "bb4-bb6a", "bb4-bb6b"]
   },
   "bb5" => {
       :ssh_port => 2025,
       :eapi_port => 4045,
       :mgmt_ip => "192.168.100.15",
       :connections => ["bb2-bb5", "bb3-bb5a", "bb3-bb5b", "bb4-bb5", "bb5-bb6"]
   },
   "bb6" => {
       :ssh_port => 2026,
       :eapi_port => 4046,
       :mgmt_ip => "192.168.100.16",
       :connections => ["bb4-bb6a", "bb4-bb6b", "bb5-bb6", "bb6-controller"]
   }
  }
Vagrant.configure("2") do |config|

  switches.each_with_index do |(hostname,info),index|

    config.vm.define hostname do |sw|

      sw.vm.box = image_version

      # Create a forwarded port mapping which allows access to eAPI and ssh on specific port
      sw.vm.network "forwarded_port", guest: 443, host: info[:eapi_port]
      #sw.vm.network "forwarded_port", guest: 22, host: info[:ssh_port]
      
      # Create a private network,  a dummy address is used in the Vagrantfile but will have no effect within vEOS
      sw.vm.network "private_network", ip: info[:mgmt_ip], virtualbox__intnet:true, auto_config: false
 
      # Customize the NIC interfaces and switch interconnectivity, note this was made for virtualBox
      sw.vm.provider :virtualbox do |vb|
        
        #Note: nic1 is always Management1 which is set to dhcp in the basebox.
        #Configuring the Interfaces for all the Switches snf how they are interconnected. Note promiscious mode is enabled
        i = 2
        for connection in info[:connections]
          vb.customize ["modifyvm", :id, "--nic#{i}", "intnet", "--intnet#{i}", connection, "--nictype#{i}", "82540EM", "--nicpromisc#{i}", "allow-vms"]
          i +=1
        end
        #Setting the Memory to be used by the switch (2048 is recommended)
        vb.memory = "1536"
      end
      #This section allows you to specify initial base config for the differnt switches. 
      #Config files are in format config-bb1.sh for example
      sw.vm.provision :shell, path: "config-#{hostname}.sh", args: "#{hostname}"
        
    end
  end

  config.vm.define "controller" do |controller|
    controller.vm.box = "ubuntu/trusty64"
    
    # Create a private network,  a dummy address is used in the Vagrantfile but will have no effect within vEOS
    controller.vm.network "forwarded_port", guest: 5001, host: 5002
    controller.vm.network "private_network", ip: "10.10.10.10", virtualbox__intnet:true, auto_config: true

    # Customize the NIC interfaces and switch interconnectivity, note this was made for virtualBox
    controller.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--nic2", "intnet", "--intnet2", "bb1-controller", "--nictype2", "82540EM", "--nicpromisc2", "allow-vms"]
    end
   
    controller.vm.provision :shell, path: "bootstrap-controller.sh"
  end  
end
  