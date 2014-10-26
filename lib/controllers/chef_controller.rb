class ChefController
  def self.install_chef_server
    host = '192.168.20.12'
    user = 'vagrant'
    password= 'vagrant'
    chef_server_file = "chef-server-core-12.0.0_rc.5-1.el5.x86_64.rpm"
    chef_server_url = "https://packagecloud.io/chef/stable/download?distro=6&filename=#{chef_server_file}"
    chef_server_local_path = "/tmp/#{chef_server_file}"

    Net::SSH.start(host, user, :password => password) do |ssh|
      puts I18n.t('chef.downloading_chef_server')
      ssh.exec!("curl -L '#{chef_server_url}' -o #{chef_server_local_path}")
      ssh.exec!("sudo rpm -ivh #{chef_server_local_path}")
      ssh.exec!("chef-server-ctl reconfigure")

      client_key = ssh.exec!("sudo chef-server-ctl user-create haas-api HAAS Api haas@ossom.io abc123")
      File.write("#{ENV['HOME']}/.haas/haas-api.pem", client_key)

      org_validator_key = ssh.exec!("sudo chef-server-ctl org-create haas Hadoop as a Service --association_user haas-api")
      File.write("#{ENV['HOME']}/.haas/haas-validator.pem", org_validator_key)
    end
  end

  def.write_knife_config_file
    working_dir = "#{ENV['HOME']}/.haas/"

    conf = %{
      log_level                    :info
      log_location               STDOUT
      node_name               "haas-api"
      client_key                  "#{working_dir}/haas-api.pem"
      validation_client_name   "haas-validator"
      validation_key           "#{working_dir}/haas-validator.pem"
      chef_server_url        "https://192.168.20.12/organizations/haas"
      cache_type               'BasicFile'
      cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
      cookbook_path         ["#{working_dir}/../cookbooks"]
      }

    File.write("#{ENV['HOME']}/.haas/knife.rb", conf)
  end


  def bootstrap_node
    host = '192.168.20.12'
    user = 'vagrant'
    password= 'vagrant'

    require 'chef'
    require 'chef/knife'
    require 'chef/knife/bootstrap'
    require 'chef/knife/core/bootstrap_context'
    require 'chef/knife/ssh'
    require 'net/ssh'
    require 'net/ssh/multi'

    config_file = File.exists?(File.join(Dir.getwd, '.haas', 'knife.rb')) ?
                  File.join(Dir.getwd, '.haas', 'knife.rb') :
                  File.join(File.expand_path('~'), '.haas', 'knife.rb')
    Chef::Config.from_file(config_file)
    kb = Chef::Knife::Bootstrap.new
    kb.config[:ssh_user]       = user
    kb.config[:ssh_password]       = password
#    kb.config[:run_list]       = options[:run_list]
    kb.config[:use_sudo]       = true
    kb.config[:chef_node_name] = name
    kb.config[:identity_file] = "/home/jpellet/.haas/vagrant"
    kb.config[:distro] = 'chef-full'
    kb.name_args = [host]
    kb.run
  end
end


