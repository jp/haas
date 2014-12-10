require 'active_record'
require 'haas/config'
require 'models/key_pair'
require 'models/node'
require 'models/cluster'
require 'haas/aws'
require 'haas/chef'
require 'haas/blueprints'
require 'haas/utils'

class Haas
  def self.launch
    Haas::Aws.connect
    @cluster=Haas::Cluster.create(
      :aws_region => Haas::Aws.region,
      :ssh_user => Haas::Aws.ssh_user,
      :distro => "ubuntu12"
    )
    if Haas::Aws.nb_instance_available >= Haas::Config.options[:nb_instances].to_i
      Haas::Aws.create_key_pair
      Haas::Aws.launch_instances
    else
      puts "There is not enough instances available.\nYou can request a limit increase here : https://aws.amazon.com/support/createCase?serviceLimitIncreaseType=ec2-instances&type=service_limit_increase"
      exit
    end

    Haas::ChefProvider.setup_cluster
    Haas::Blueprints.post_blueprints

    puts "\n"
    puts "=========== installation report =============="
    puts "Ambari is finalizing the installation"
    puts "You can access Ambari to manage your cluster at the following address:"
    puts "http://#{@cluster.get_ambari_server.public_dns_name}:8080/"
    puts "user: admin"
    puts "password: admin"
    puts "\n"
    puts "Nodes of the cluster:"
    @cluster.nodes.each do |node|
      puts "    #{node.public_dns_name}"
    end
    puts "\n"
    puts "You can use this SSH key to log into each node as user #{@cluster.ssh_user}"
    puts @cluster.identity_file_path
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
    Haas::Aws.connect
    Haas::Aws.terminate_cluster Cluster.first
  end

  def self.cluster
    return @cluster
  end

  def self.set_cluster cluster
    @cluster = cluster
  end
end
