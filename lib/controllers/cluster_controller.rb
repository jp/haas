class ClusterController
  def self.create_key_pair
    KeyPair.create(name: "cluster-gem-key")
  end
end


