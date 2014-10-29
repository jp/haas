class AwsController

# Get the nb limit of instances on AWS with :
# http://docs.aws.amazon.com/AWSRubySDK/latest/AWS/EC2/Client.html#describe_account_attributes-instance_method
# ec2 = AWS::EC2.new
# ec2.client.describe_account_attributes.data[:account_attribute_set].select {|a| a[:attribute_name]=="max-instances"}
# 
# existing instances in region : 
# ec2.instances.inject({}) { |m, i| m[i.id] = i.status; m }


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

  def launch_instances(region, count, type)
    image_id = CENTOS_7_IMAGES[region]

    ec2.instances.create({
      :image_id => image_id,
      :instance_type => "m3.medium",
      :key_name => "haas-manual",
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
      }],
      :count => 1
    })
  end
end


