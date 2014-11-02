class Haas
  class Cluster < ActiveRecord::Base
    before_create :generate_name
    has_many :nodes

    def generate_name
      random_str = (0...8).map { (65 + rand(26)).chr }.join
      self.name = "HAAS-#{random_str}"
    end
  end
end
