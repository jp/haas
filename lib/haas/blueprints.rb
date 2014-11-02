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
      {
        "blueprint" => "multi-node-hdfs-yarn",
        "default_password" => "my-super-secret-password",
        "host_groups" => [
          {
            "name" => "master",
            "hosts" => [
              {
                "fqdn" => "c6401.ambari.apache.org"
              }
            ]
          },
          {
            "name" => "slaves",
            "hosts" => [
              {
                "fqdn" => "c6402.ambari.apache.org"
              },
              {
                "fqdn" => "c6403.ambari.apache.org"
              }
            ]
          }
        ]
      }
    end

  end
end
