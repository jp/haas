class Haas
  class ChefProvider

    COOKBOOK_PATH = File.join(Haas::Config::WORKING_DIR, 'cookbooks')

    def self.setup_cluster
      install_chef_server
      write_knife_config_file
      cookbooks=[
        {'name' => 'ambari', 'url' => "https://supermarket.getchef.com/cookbooks/ambari/download" },
        {'name' => 'apt', 'url' => "https://supermarket.getchef.com/cookbooks/apt/download" }
      ]
      cookbooks.each do |cb|
        download_cookbook cb['name'], cb['url']
      end
      upload_cookbook
      setup_environment
      threads = []
      Haas.cluster.nodes.each do |node|
        threads << Thread.new { bootstrap_node(node) }
      end
      threads.each { |thr| thr.join }
    end

    def self.chef_install_cmd
      install_cmd = {
        'centos6'    => 'curl https://packagecloud.io/install/repositories/chef/stable/script.rpm | sudo bash && sudo yum install chef-server-core-12.0.0-1.el6.x86_6',
        'ubuntu12' => 'curl https://packagecloud.io/install/repositories/chef/stable/script.deb | sudo bash && sudo apt-get install chef-server-core=12.0.0-1'
      }
      install_cmd[Haas.cluster.distro]
    end

    def self.install_chef_server
      require 'net/ssh'
      chef_server = Haas.cluster.get_chef_server

      Net::SSH.start(
        chef_server.public_dns_name, Haas.cluster.ssh_user,
        :host_key => "ssh-rsa",
        :encryption => "blowfish-cbc",
        :keys => [ Haas.cluster.identity_file_path ],
        :compression => "zlib"
      ) do |ssh|
        puts "Entering chef server installation on the node #{chef_server.public_dns_name}. This may take a while."
        puts "Disable iptables"
        ssh.exec!("sudo service iptables stop")
        puts "Downloading and installing the chef server."
        ssh.exec!(self.chef_install_cmd)
        puts "Configuring chef server."
        ssh.exec!("sudo mkdir -p /etc/opscode/")
        ssh.exec!(%{sudo bash -c "echo \\"nginx['non_ssl_port'] = false\\" >> /etc/opscode/chef-server.rb"})
        ssh.exec!("sudo chef-server-ctl reconfigure")

        client_key = ""
        while !client_key.include?("BEGIN RSA PRIVATE KEY") do
          client_key = ssh.exec!("sudo chef-server-ctl user-create haas-api HAAS Api haas@ossom.io abc123")
        end
        File.write(Haas.cluster.chef_client_pem_path, client_key)

        org_validator_key = ssh.exec!("sudo chef-server-ctl org-create haas Hadoop as a Service --association_user haas-api")
        File.write(Haas.cluster.chef_validator_pem_path, org_validator_key)
      end
    end

    def self.write_knife_config_file
      conf = %{
        log_level                    :info
        log_location               STDOUT
        node_name               "haas-api"
        client_key                  "#{Haas.cluster.chef_client_pem_path}"
        validation_client_name   "haas-validator"
        validation_key           "#{Haas.cluster.chef_validator_pem_path}"
        chef_server_url        "https://#{Haas.cluster.get_chef_server.public_dns_name}/organizations/haas"
        cache_type               'BasicFile'
        cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
        cookbook_path         ["#{COOKBOOK_PATH}"]
        environment             "#{Haas.cluster.name}"
      }

      File.write(Haas.cluster.knife_config_path, conf)
    end


    def self.bootstrap_node node
      require 'chef'
      require 'chef/knife'
      require 'chef/knife/bootstrap'
      require 'chef/knife/core/bootstrap_context'
      require 'chef/knife/ssh'
      require 'net/ssh'
      require 'net/ssh/multi'

      puts "Bootstrapping node #{node.public_dns_name}"

      run_list = ["recipe[ambari::agent]"]
      run_list << "recipe[ambari::server]" if node.ambari_server

      Chef::Config.from_file(Haas.cluster.knife_config_path)
      kb = Chef::Knife::Bootstrap.new
      kb.config[:ssh_user] = Haas.cluster.ssh_user
      kb.config[:run_list] = run_list
      kb.config[:use_sudo] = true
      kb.config[:identity_file] = Haas.cluster.identity_file_path
      kb.config[:distro] = 'chef-full'
      kb.name_args = [node.public_dns_name]
      kb.run
    end

    def self.download_cookbook cookbook_name, url
      require 'open-uri'
      require 'zlib'
      require 'archive/tar/minitar'

      cookbooks_dir = File.join(Haas::Config::WORKING_DIR, 'cookbooks')
      Dir.mkdir(cookbooks_dir) unless File.exists?(cookbooks_dir)
      archive_path = File.join(cookbooks_dir, "#{cookbook_name}.tar.gz")
      open(archive_path, 'wb') do |file|
        file << open(url).read
      end
      tgz = Zlib::GzipReader.new(File.open(archive_path, 'rb'))
      Archive::Tar::Minitar.unpack(tgz, cookbooks_dir)
    end

    def self.upload_cookbook
      require 'chef'
      require 'chef/cookbook_uploader'

      puts "Uploading cookbooks to the chef server."

      Chef::Config.from_file(Haas.cluster.knife_config_path)
      cookbook_repo = Chef::CookbookLoader.new(COOKBOOK_PATH)
      cookbook_repo.load_cookbooks
      cbs = []
      cookbook_repo.each do |cookbook_name, cookbook|
        cbs << cookbook
      end
      Chef::CookbookUploader.new(cbs,:force => false, :concurrency => 10).upload_cookbooks
    end

    def self.setup_environment
      require 'chef/environment'
      require 'chef/rest'
      ambari_server_fqdn = Haas.cluster.get_ambari_server

      override_attributes = {
        :ambari => {
          :server_fqdn => ambari_server_fqdn.private_dns_name
        }
      }

      Chef::Config.from_file(Haas.cluster.knife_config_path)
      environment = Chef::Environment.new
      environment.name(Haas.cluster.name)
      environment.description("haas hadoop cluster")
      environment.override_attributes(override_attributes)
      environment.save
    end
  end
end
