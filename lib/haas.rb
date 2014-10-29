require 'net/ssh'
require 'active_record'
require 'aws-sdk'
require 'haas_config'
require 'models/key_pair'
require 'models/node'
require 'controllers/cluster_controller'
require 'controllers/aws_controller'
require 'controllers/chef_controller'

# remove warning for not providing locales
I18n.enforce_available_locales = true
I18n.load_path += Dir.glob( File.dirname(__FILE__) + "/locales/*.{rb,yml}" )

# Authenticate AWS

AWS.config(
  access_key_id: ENV['AWS_KEY'],
  secret_access_key: ENV['AWS_SECRET'],
  region: 'us-west-2'
)

# Create Haas folder

Dir.mkdir(HaasConfig::WORKING_DIR) unless File.exists?(HaasConfig::WORKING_DIR)

############ create sqlite db in memory ############

SQLITE_DB = ENV['SQLITE_DB'] || File.join(HaasConfig::WORKING_DIR,"haas_sqlite3.db")

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: SQLITE_DB
)

if !File.file?(SQLITE_DB)
  ActiveRecord::Schema.define do
    create_table :key_pairs do |table|
      table.column :name, :string
      table.column :private_key, :string
    end
    add_index :key_pairs, :name, unique: true

    create_table :nodes do |table|
      table.column :instance_id, :string
      table.column :ip_address, :string
      table.column :private_ip_address, :string
      table.column :chef_server, :boolean
    end
  end
end
