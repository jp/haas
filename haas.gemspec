Gem::Specification.new do |s|
  s.name = 'haas'
  s.version = '0.0.5'
  s.date = '2014-11-22'
  s.summary = "Launch big data cluster in the cloud"
  s.description = "Automatically launch Hadoop or Spark clusters in the cloud"
  s.author = "Julien Pellet"
  s.email = 'jp@julienpellet.com'
  s.executables = %w{ haas }
  s.homepage = 'http://github.com/jp/haas'
  s.license = 'Apache 2.0'
  s.files = Dir.glob("lib/**/*", File::FNM_DOTMATCH).reject {|f| File.directory?(f) }

  s.add_dependency "activerecord", "~> 4.1"
  s.add_dependency "sqlite3", "~> 1.3"
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
