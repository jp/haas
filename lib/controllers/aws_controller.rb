require 'aws-sdk'

class AwsController
  AWS.config(
    access_key_id: ENV['AWS_KEY'],
    secret_access_key: ENV['AWS_SECRET'],
    region: 'us-west-2'
  )
  EC2 = AWS::EC2.new
  IDENTITY_FILE = File.join(Haas::Config::WORKING_DIR,"/ssh-haas.pem")
  KEYPAIR_NAME = "haas-gem"
  CENTOS_IMAGES = {
    "6.5" => {
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

  def self.nb_instance_available
    account_attributes = EC2.client.describe_account_attributes\
    .data[:account_attribute_set]\
    .inject({}) do |m, i|
      m[i[:attribute_name]] = i[:attribute_value_set].first[:attribute_value]; m
    end

    max_instances = account_attributes["max-instances"].to_i
    return max_instances - nb_running_instances
  end

  def self.nb_running_instances
    EC2.instances.inject({}) { |m, i| i.status == :running ? m[i.id] = i.status : nil; m }.length
  end

  def self.create_key_pair
    key_pair = Haas::KeyPair.create(name: KEYPAIR_NAME)
    File.write(IDENTITY_FILE, key_pair.private_key)
    File.chmod(0600, IDENTITY_FILE)
  end

  def self.launch_instances(cluster, region, count, instance_type)
    image_id = CENTOS_IMAGES["6.5"][region]

    instances = EC2.instances.create({
      :image_id => image_id,
      :instance_type => instance_type,
      :key_name => KEYPAIR_NAME,
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
      :count => count
    })

    print I18n.t('haas.waiting_for_instances_to_start')
    while nb_running_instances < count do
      print '.'
      $stdout.flush
      sleep 1
    end
    print I18n.t('haas.done')

    instances.each do |instance|
      Haas::Node.create(
        cluster_id: cluster.id,
        instance_id: instance.id,
        public_ip_address: instance.ip_address,
        public_dns_name: instance.public_dns_name,
        private_ip_address: instance.private_ip_address,
        private_dns_name: instance.private_dns_name
      )
    end

  end
end


