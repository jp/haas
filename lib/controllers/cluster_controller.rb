class ClusterController

  def self.launch()
    count = 5

    if AwsController.nb_instance_available < count
      AwsController.create_key_pair
      AwsController.launch_instances('us-west-2',count,'m3.medium')
    else
      puts I18n.t('chef.not_enough_instances_available')
    end
  end

end


