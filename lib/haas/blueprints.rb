class Haas
  class Blueprints

    def self.post_blueprints
      ambari = Haas.cluster.get_ambari_server
      puts "Wait until ambari server is launched"
      while !Haas::Utils.is_port_open?(ambari.public_dns_name,8080)
        print '.'
        sleep 1
      end
      puts ' done.'

      puts "Wait 20 seconds for the nodes to connect to ambari."
      sleep 20
      puts "Done."

      post_json(ambari.public_dns_name,8080,'/api/v1/blueprints/haas-blueprint',get_blueprint)
      post_json(ambari.public_dns_name,8080,'/api/v1/clusters/haas-cluster',get_cluster)
    end

    def self.post_json(host, port, url, params)
      req = Net::HTTP::Post.new(url)
      req.body = params.to_json
      req.basic_auth("admin", "admin")
      req["X-Requested-By"] = "HaaS"
      response = Net::HTTP.new(host, port).start {|http| http.request(req) }
    end

    def self.get_blueprint
      {
        "configurations" => [
          {
            "hive-site"=> {
              "javax.jdo.option.ConnectionPassword"=> "hive"
            }
          },
          {
            "nagios-env" => {
               "nagios_contact" => "admin@localhost"
            }
          }
        ],
        "host_groups" => [
          {
            "name" => "master",
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
              },
              {
                "name" => "GANGLIA_MONITOR"
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
              },
              {
                "name" => "GANGLIA_MONITOR"
              }
            ],
            "cardinality" => "1+"
          }
        ],
       "Blueprints" => {
          "stack_name" => "HDP",
          "stack_version" => "2.2"
        }
      }
    end


    def self.get_cluster
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
        "blueprint" => "haas-blueprint",
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
