class Haas
  class Cluster < ActiveRecord::Base
    before_create :generate_name
    has_many :nodes, dependent: :destroy

    def generate_name
      random_str = (0...8).map { (65 + rand(26)).chr }.join
      self.name = "HAAS-#{random_str}"
    end

    def get_chef_server
      self.nodes.where('nodes.chef_server=?',true)
    end

    def get_ambari_server
      self.nodes.where('nodes.ambari_server=?',true)
    end
  end
end
