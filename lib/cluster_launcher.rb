require 'net/ssh'
require 'active_record'
require 'aws-sdk'
require 'models/key_pair'
require 'models/node'
require 'controllers/cluster_controller'

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

HAAS_WORKING_DIR = File.join(File.expand_path('~'), '.haas')
Dir.mkdir(HAAS_WORKING_DIR) unless File.exists?(HAAS_WORKING_DIR)

############ create sqlite db in memory ############

SQLITE_DB = ENV['SQLITE_DB'] || File.join(HAAS_WORKING_DIR,"haas_sqlite3.db")

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
      table.column :ip, :string
      table.column :chef_server, :boolean
    end
  end
end
