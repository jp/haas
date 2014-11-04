require 'active_record'
require 'haas/config'
require 'models/key_pair'
require 'models/node'
require 'models/cluster'
require 'haas/aws'
require 'haas/chef'
require 'haas/blueprints'

class Haas
  def self.launch
    count = 2
    region = 'us-west-2'
    instance_type = 'm3.medium'

    cluster=Haas::Cluster.create
    if Haas::Aws.nb_instance_available >= count
      Haas::Aws.create_key_pair
      Haas::Aws.launch_instances(cluster, region, count, instance_type)
    else
      puts I18n.t('haas.not_enough_instances_available')
      exit
    end

    Haas::Chef.setup_cluster(cluster)

  end

  def self.show
    Haas::Cluster.all.each do |cluster|
      puts "Cluster - #{cluster.name}"
      cluster.nodes.each do |node|
        puts "        #{node.instance_id} - #{node.ip_address} - #{node.private_ip_address}"
      end
    end
  end

  def self.terminate cluster_name
    Haas::Aws.terminate_cluster Cluster.first
  end

end
