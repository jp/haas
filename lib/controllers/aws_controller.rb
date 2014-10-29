class AwsController

# Get the nb limit of instances on AWS with :
# http://docs.aws.amazon.com/AWSRubySDK/latest/AWS/EC2/Client.html#describe_account_attributes-instance_method
# ec2 = AWS::EC2.new
# ec2.client.describe_account_attributes.data[:account_attribute_set].select {|a| a[:attribute_name]=="max-instances"}
# 
# existing instances in region : 
# ec2.instances.inject({}) { |m, i| m[i.id] = i.status; m }

  IDENTITY_FILE = File.join(HAAS_WORKING_DIR,"/ssh-haas.pem")
  KEYPAIR_NAME = "haas-gem"
  CENTOS_7_IMAGES = {
    "us-east-1"=>"ami-96a818fe",
    "us-west-2"=>"ami-c7d092f7",
    "us-west-1"=>"ami-6bcfc42e",
    "eu-west-1"=>"ami-e4ff5c93",
    "ap-southeast-1"=>"ami-aea582fc",
    "ap-southeast-2"=>"ami-bd523087",
    "ap-northeast-1"=>"ami-89634988",
    "sa-east-1"=>"ami-bf9520a2"
  }

  def self.nb_instance_available
    ec2 = AWS::EC2.new
    account_attribute = ec2.client.describe_account_attributes.data[:account_attribute_set].select {|a| a[:attribute_name]=="max-instances"}
    max_instances = account_attribute.first[:attribute_value_set].first[:attribute_value].to_i
    running_instances = ec2.instances.inject({}) { |m, i| m[i.id] = i.status; m }.length
    return max_instances - running_instances;
  end

  def self.create_key_pair
    key_pair = KeyPair.create(name: KEYPAIR_NAME)
    File.write(IDENTITY_FILE, key_pair.private_key)
    File.chmod(0600, IDENTITY_FILE)
  end

  def self.launch_instances(region, count, instance_type)
    image_id = CENTOS_7_IMAGES[region]

    ec2.instances.create({
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
  end
end


