class ClusterController

  def self.launch
    count = 2
    cluster=Haas::Cluster.create
    if Haas::Aws.nb_instance_available >= count
      Haas::Aws.create_key_pair
      Haas::Aws.launch_instances(cluster, 'us-west-2',count,'m3.medium')
    else
      puts I18n.t('haas.not_enough_instances_available')
    end
  end

  def self.show
    Haas::Node.all.each do |node|
      puts "#{node.instance_id} - #{node.ip_address} - #{node.private_ip_address}"
    end
  end

end


