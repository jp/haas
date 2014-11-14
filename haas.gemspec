Gem::Specification.new do |s|
  s.name        = 'haas'
  s.version     = '0.0.1'
  s.date        = '2014-10-01'
  s.summary     = "Launch big data cluster in the cloud"
  s.description     = "Automatically launch Hadoop or Spark clusters in the cloud"
  s.authors     = ["Julien Pellet"]
  s.email       = 'jp@julienpellet.com'
  s.files        << "lib/haas.rb"
  s.files        << "lib/haas/config.rb"
  s.files        << "lib/models/key_pair.rb"
  s.files        << "lib/models/node.rb"
  s.files        << "lib/models/cluster.rb"
  s.files        << "lib/haas/aws.rb"
  s.files        << "lib/haas/chef.rb"
  s.files        << "lib/haas/blueprints.rb"
  s.files        << "lib/haas/utils.rb"
  s.executables = ['haas']
  s.homepage    = 'http://github.com/jp/haas'
  s.license       = 'Apache 2.0'

  s.add_dependency "activerecord", "~> 4.1"
  s.add_dependency "sqlite3", "~> 1.3"
  s.add_dependency "rack", "~> 1.5"
  s.add_dependency "thin", "~> 1.6"
  s.add_dependency "aws-sdk", "~> 1.55"
  s.add_dependency "net-ssh", "~> 2.9"
  s.add_dependency "chef", "~> 11.16"
  s.add_dependency "mixlib-cli", "~> 1.5"

  s.add_development_dependency "factory_girl", "~> 4.4"
  s.add_development_dependency "faker", "~> 1.3"
  s.add_development_dependency "rspec", "~> 2.14"
  s.add_development_dependency "simplecov", "~> 0.8"
  s.add_development_dependency "shoulda", "~> 3.5"

end
