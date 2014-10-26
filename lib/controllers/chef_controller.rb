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
end


