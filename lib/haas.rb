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

    @cluster=Haas::Cluster.create
    if Haas::Aws.nb_instance_available >= count
      Haas::Aws.create_key_pair @cluster
      Haas::Aws.launch_instances(@cluster, region, count, instance_type)
    else
      puts "There is not enough instances available.\nYou can request a limit increase here : https://aws.amazon.com/support/createCase?serviceLimitIncreaseType=ec2-instances&type=service_limit_increase"
      exit
    end

    Haas::ChefProvider.setup_cluster
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

  def self.cluster
    return @cluster
  end

  def self.set_cluster cluster
    @cluster = cluster
  end
end
