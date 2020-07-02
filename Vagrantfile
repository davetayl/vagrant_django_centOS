Vagrant.configure("2") do |config|
  config.vm.define "djangoapp" do |djangoapp|
    config.vm.box = "centos/8"
	config.vm.provider "virtualbox" do |vb|
		vb.memory = 1024
		vb.cpus = 1
	end
	djangoapp.vm.network "forwarded_port", guest: 80, host: 80
	djangoapp.vm.network "forwarded_port", guest: 443, host: 443
	djangoapp.vm.provision "shell", path: "./provision-djangoapp.sh"
  end
end