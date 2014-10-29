class ClusterController

  def self.launch
    count = 2
    if AwsController.nb_instance_available < count
      AwsController.create_key_pair
      instances = AwsController.launch_instances('us-west-2',count,'m3.medium')
      instances.each do |instance|
        Node.create(
          instance_id: instance.id,
          ip_address: instance.ip_address,
          private_ip_address: instance.private_ip_address
        )
      end
    else
      puts I18n.t('chef.not_enough_instances_available')
    end
  end

  def self.show
    Node.all.each do |node|
      puts "#{node.instance_id} - #{node.ip_address} - #{node.private_ip_address}"
    end
  end

end


