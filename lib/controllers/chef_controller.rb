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
    end
  end
end


