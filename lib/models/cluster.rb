class Haas
  class Cluster < ActiveRecord::Base
    before_create :generate_name
    after_create :mkdir_cluster_home
    has_many :nodes, dependent: :destroy

    def mkdir_cluster_home
      require 'fileutils'
      FileUtils.mkdir_p self.working_dir_path
    end

    def working_dir_path
      File.join(Haas::Config::WORKING_DIR, self.name)
    end

    def identity_file_path
      File.join(self.working_dir_path,"ssh-#{self.name}.pem")
    end

    def chef_client_pem_path
      File.join(self.working_dir_path,"haas-api.pem")
    end

    def chef_validator_pem_path
      File.join(self.working_dir_path,"haas-validator.pem")
    end

    def knife_config_path
      File.join(self.working_dir_path,"knife.rb")
    end

    def generate_name
      random_str = (0...8).map { (65 + rand(26)).chr }.join
      self.name = "HAAS-#{random_str}"
    end

    def get_chef_server
      chef_server = self.nodes.where('nodes.chef_server=?',true)
      if chef_server.first
        return chef_server.first
      else
        node = self.nodes.first
        node.chef_server = true
        node.save
      end
    end

    def get_ambari_server
      ambari_server = self.nodes.where('nodes.ambari_server=?',true)
      if ambari_server.first
        return ambari_server.first
      else
        node = self.nodes.where('nodes.chef_server=?',false).first
        node.ambari_server = true
        node.save
      end
    end
  end
end
