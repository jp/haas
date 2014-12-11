require 'aws-sdk'

class Haas
  class Aws
    CENTOS_IMAGES = {
      "6.5" => {
        "ssh_user" => "root",
        "us-east-1"=>"ami-8997afe0",
        "us-west-2"=>"ami-b6bdde86",
        "us-west-1"=>"ami-1a013c5f",
        "eu-west-1"=>"ami-42718735",
        "ap-southeast-1"=>"ami-a08fd9f2",
        "ap-southeast-2"=>"ami-e7138ddd",
        "ap-northeast-1"=>"ami-81294380",
        "sa-east-1"=>"ami-7d02a260"
      },
      "7" => {
        "ssh_user" => "root",
        "us-east-1"=>"ami-96a818fe",
        "us-west-2"=>"ami-c7d092f7",
        "us-west-1"=>"ami-6bcfc42e",
        "eu-west-1"=>"ami-e4ff5c93",
        "ap-southeast-1"=>"ami-aea582fc",
        "ap-southeast-2"=>"ami-bd523087",
        "ap-northeast-1"=>"ami-89634988",
        "sa-east-1"=>"ami-bf9520a2"
      }
    }

    UBUNTU_IMAGES = {
      "12.04" => {
        "ssh_user" => "ubuntu",
        "ap-northeast-1" => "ami-f96b40f8",
        "ap-southeast-1" => "ami-da1e3988",
        "eu-central-1" => "ami-643c0a79",
        "eu-west-1" => "ami-6ca1011b",
        "sa-east-1" => "ami-11d4610c",
        "us-east-1" => "ami-34cc7a5c",
        "us-west-1" => "ami-b7515af2",
        "ap-southeast-2" => "ami-9f0e6ca5",
        "us-west-2" => "ami-0f47053f"
      }
    }

    def self.connect
      @region = Haas::Config.options[:aws_region] || 'us-east-1'
      AWS.config(
        access_key_id: ENV['AWS_KEY'],
        secret_access_key: ENV['AWS_SECRET'],
        region: region
      )
      @ec2 = AWS::EC2.new
    end

    def self.ec2
      @ec2
    end

    def self.region
      @region
    end

    def self.ssh_user
      UBUNTU_IMAGES["12.04"]["ssh_user"]
    end

    def self.nb_instance_available
      account_attributes = ec2.client.describe_account_attributes\
      .data[:account_attribute_set]\
      .inject({}) do |m, i|
        m[i[:attribute_name]] = i[:attribute_value_set].first[:attribute_value]; m
      end

      max_instances = account_attributes["max-instances"].to_i
      return max_instances - nb_running_instances
    end

    def self.nb_running_instances
      ec2.instances.inject({}) { |m, i| i.status == :running ? m[i.id] = i.status : nil; m }.length
    end

    def self.create_key_pair
      key_pair = Haas::KeyPair.create(name: Haas.cluster.name)
      File.write(Haas.cluster.identity_file_path, key_pair.private_key)
      File.chmod(0600, Haas.cluster.identity_file_path)
    end

    def self.launch_instances
      image_id = UBUNTU_IMAGES["12.04"][region]

      if !ec2.security_groups.filter('group-name', 'haas-security-group').first
        security_group = ec2.security_groups.create('haas-security-group')
        security_group.authorize_ingress(:tcp, 22)
        security_group.authorize_ingress(:tcp, 80)
        security_group.authorize_ingress(:tcp, 443)
        security_group.authorize_ingress(:tcp, 8080)
        security_group.authorize_ingress(:tcp, 0..65535, security_group)
        security_group.authorize_ingress(:udp, 0..65535, security_group)
        security_group.authorize_ingress(:icmp, -1, security_group)
      end

      instances = ec2.instances.create({
        :image_id => image_id,
        :instance_type => Haas::Config.options[:instance_type],
        :key_name => Haas.cluster.name,
        :security_groups => ['haas-security-group'],
        :block_device_mappings => [
          {
            :device_name => "/dev/sda1",
            :ebs => {
              :volume_size => 8, # 8 GiB
              :delete_on_termination => true
            }
          },
          {
            :device_name => "/dev/sdf",
            :virtual_name => "ephemeral0"
          }
        ],
        :count => Haas::Config.options[:nb_instances].to_i
      })

      print "Waiting for the instances to start "
      while instances.any? {|i| i.status == :pending; } do
        print '.'
        sleep 1
      end
      puts " done"

      print "Waiting for the instances to be initialized and accessible "
      while !is_cluster_ssh_open?(instances) do
        print '.'
        sleep 1
      end
      puts " done"

      instances.each do |instance|
        Haas::Node.create(
          cluster_id: Haas.cluster.id,
          instance_id: instance.id,
          public_ip_address: instance.ip_address,
          public_dns_name: instance.public_dns_name,
          private_ip_address: instance.private_ip_address,
          private_dns_name: instance.private_dns_name
        )
      end
    end

    def self.terminate_cluster cluster
      ec2.client.terminate_instances({
        instance_ids: cluster.nodes.map(&:instance_id)
      })
      cluster.destroy
    end

    def self.is_cluster_ssh_open?(instances)
      instances.each do |instance|
        return false unless Haas::Utils.is_port_open?(instance.public_dns_name,22)
      end
      return true
    end

  end
end
