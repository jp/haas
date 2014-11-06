class Haas
  class Blueprints

    def self.get_blueprint
      {
        "host_groups" => [
          {
            "name" => "master",
            "configurations" => [
              {
                "nagios-env" => {
                  "nagios_contact" => "me@my-awesome-domain.example"
                }
              }
            ],
              "components" => [
              {
                "name" => "NAMENODE"
              },
              {
                "name" => "SECONDARY_NAMENODE"
              },
              {
                "name" => "RESOURCEMANAGER"
              },
              {
                "name" => "HISTORYSERVER"
              },
              {
                "name" => "NAGIOS_SERVER"
              },
              {
                "name" => "GANGLIA_SERVER"
              },
              {
                "name" => "ZOOKEEPER_SERVER"
              }
            ],
            "cardinality" => "1"
          },
          {
            "name" => "slaves",
            "components" => [
              {
                "name" => "DATANODE"
              },
              {
                "name" => "HDFS_CLIENT"
              },
              {
                "name" => "NODEMANAGER"
              },
              {
                "name" => "YARN_CLIENT"
              },
              {
                "name" => "MAPREDUCE2_CLIENT"
              },
              {
                "name" => "ZOOKEEPER_CLIENT"
              }
            ],
            "cardinality" => "1+"
          }
        ],
       "Blueprints" => {
          "stack_name" => "HDP",
          "stack_version" => "2.1"
        }
      }
    end


    def self.get_cluster(cluster)
      masters = []
      slaves = []
      nb_masters = 1
      Haas.cluster.nodes.each do |node|
        if masters.length < nb_masters
          masters << { "fqdn" => node.private_dns_name }
        else
          slaves << { "fqdn" => node.private_dns_name }
        end
      end

      {
        "blueprint" => "multi-node-hdfs-yarn",
        "default_password" => "my-super-secret-password",
        "host_groups" => [
          {
            "name" => "master",
            "hosts" => masters
          },
          {
            "name" => "slaves",
            "hosts" => slaves
          }
        ]
      }
    end

  end
end
