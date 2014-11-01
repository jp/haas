class ChefController

# net ssh use identify file
# http://stackoverflow.com/questions/6833514/cannot-connect-using-keys-with-ruby-and-net-ssh

  CONFIG_FILE = File.join(HaasConfig::WORKING_DIR, 'knife.rb')
  COOKBOOK_PATH = File.join(HaasConfig::WORKING_DIR, 'cookbooks')

  def self.install_chef_server
    require 'net/ssh'

    host = '192.168.20.12'
    user = 'vagrant'
    password= 'vagrant'
    chef_server_file = "chef-server-core-12.0.0_rc.5-1.el5.x86_64.rpm"
    chef_server_url = "https://packagecloud.io/chef/stable/download?distro=6&filename=#{chef_server_file}"
    chef_server_local_path = "/tmp/#{chef_server_file}"

    Net::SSH.start(host, user, :password => password) do |ssh|
      puts I18n.t('chef.installing_chef_server')
      ssh.exec!("curl -L '#{chef_server_url}' -o #{chef_server_local_path}")
      ssh.exec!("sudo rpm -ivh #{chef_server_local_path}")
      ssh.exec!("chef-server-ctl reconfigure")

      client_key = ssh.exec!("sudo chef-server-ctl user-create haas-api HAAS Api haas@ossom.io abc123")
      File.write(File.join(Haas::WORKING_DIR,"/haas-api.pem"), client_key)

      org_validator_key = ssh.exec!("sudo chef-server-ctl org-create haas Hadoop as a Service --association_user haas-api")
      File.write(File.join(Haas::WORKING_DIR,"/haas-validator.pem"), org_validator_key)
    end
  end

  def self.write_knife_config_file
    conf = %{
      log_level                    :info
      log_location               STDOUT
      node_name               "haas-api"
      client_key                  "#{HaasConfig::WORKING_DIR}/haas-api.pem"
      validation_client_name   "haas-validator"
      validation_key           "#{HaasConfig::WORKING_DIR}/haas-validator.pem"
      chef_server_url        "https://192.168.20.12/organizations/haas"
      cache_type               'BasicFile'
      cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
      cookbook_path         ["#{COOKBOOK_PATH}"]
      }

    File.write(File.join(Haas::WORKING_DIR,"knife.rb"), conf)
  end


  def self.bootstrap_node
    host = '192.168.20.12'
    user = 'vagrant'
    password= 'vagrant'
    environment = "haas_test_env" # cluster.name

    require 'chef'
    require 'chef/knife'
    require 'chef/knife/bootstrap'
    require 'chef/knife/core/bootstrap_context'
    require 'chef/knife/ssh'
    require 'net/ssh'
    require 'net/ssh/multi'

    Chef::Config.from_file(CONFIG_FILE)
    kb = Chef::Knife::Bootstrap.new
#    kb.config[:environment] = "haas_test_env"
    kb.config[:ssh_user]       = user
    kb.config[:ssh_password]       = password
    kb.config[:run_list]       = ["recipe[ambari::server]","recipe[ambari::agent]"]
    kb.config[:use_sudo]       = true
    kb.config[:chef_node_name] = name
    kb.config[:identity_file] = File.join(Haas::WORKING_DIR,"vagrant")
    kb.config[:distro] = 'chef-full'
    kb.config[:environment] = environment
    kb.name_args = [host]
    kb.run
  end

  def self.download_cookbook cookbook_name, url
    require 'open-uri'
    require 'archive/tar/minitar'

    url = "https://supermarket.getchef.com/cookbooks/ambari/download"
    cookbook_name = "ambari"

    cookbooks_dir = File.join(HaasConfig::WORKING_DIR, 'cookbooks')
    archive_path = File.join(cookbooks_dir, "#{cookbook_name}.tar")
    unpack_dir   = File.join(cookbooks_dir, "#{cookbook_name}")
    open("https://supermarket.getchef.com/cookbooks/ambari/download") {|f|
       File.open(archive_path,"wb") do |file|
         file.puts f.read
       end
    }
    Archive::Tar::Minitar.unpack(archive_path, cookbooks_dir)
  end

  def self.upload_cookbook
    require 'chef'
    require 'chef/cookbook_uploader'

    puts I18n.t('chef.uploading_cookbooks')

    Chef::Config.from_file(CONFIG_FILE)
    cookbook_repo = Chef::CookbookLoader.new(COOKBOOK_PATH)
    cookbook_repo.load_cookbooks
    cbs = []
    cookbook_repo.each do |cookbook_name, cookbook|
      cbs << cookbook
      cookbook.freeze_version if config[:freeze]
      version_constraints_to_update[cookbook_name] = cookbook.version
    end
    Chef::CookbookUploader.new(cbs,:force => false, :concurrency => 10).upload_cookbooks
  end

  def self.setup_environment(name)
    require 'chef/environment'
    require 'chef/rest'

    name="haas_test_env"
    ambari_server_fqdn = '192.168.20.12'

    override_attributes = {
      :ambari => {
        :server_fdqn => ambari_server_fqdn
      }
    }

    Chef::Config.from_file(CONFIG_FILE)
    environment = Chef::Environment.new
    environment.name(name)
    environment.description("haas hadoop cluster")
    environment.override_attributes(override_attributes)
    environment.save

  end

end


