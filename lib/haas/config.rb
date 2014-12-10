class Haas
  class Config
    WORKING_DIR=File.join(File.expand_path('~'), '.haas')

    def self.set_options options
      @options = options
    end

    def self.options
      @options
    end

    # Create Haas folder

    Dir.mkdir(Haas::Config::WORKING_DIR) unless File.exists?(Haas::Config::WORKING_DIR)

    ############ create sqlite db in memory ############

    SQLITE_DB = ENV['SQLITE_DB'] || File.join(Haas::Config::WORKING_DIR,"haas_sqlite3.db")

    ActiveRecord::Base.establish_connection(
      adapter: "sqlite3",
      database: SQLITE_DB
    )

    if !File.file?(SQLITE_DB)
      ActiveRecord::Migration.verbose = false
      ActiveRecord::Schema.define do
        create_table :key_pairs do |table|
          table.column :name, :string
          table.column :private_key, :string
        end
        add_index :key_pairs, :name, unique: true

        create_table :clusters do |table|
          table.column :name, :string
          table.column :aws_region, :string
          table.column :ssh_user, :string
          table.column :distro, :string
        end
        add_index :clusters, :name, unique: true

        create_table :nodes do |table|
          table.column :instance_id, :string
          table.column :public_ip_address, :string
          table.column :public_dns_name, :string
          table.column :private_ip_address, :string
          table.column :private_dns_name, :string
          table.column :chef_server, :boolean
          table.column :ambari_server, :boolean
          table.column :cluster_id, :integer
        end
      end
    end

  end
end