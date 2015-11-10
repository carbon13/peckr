require 'active_record'
require 'yaml'
require 'erb'
require 'logger'

ENV['ENV'] ||= 'development'

task :default => :migrate

desc "Migrate database"
task :migrate => :environment do
  ActiveRecord::Migrator.migrate('db/migrate', ENV['VERSION'] ? ENV['VERSION'].to_i : nil )
end

task :environment do
  db_config = YAML.load(ERB.new(File.read('config/database.yml')).result)
  ActiveRecord::Base.establish_connection(db_config[ENV['ENV']])
  ActiveRecord::Base.logger = Logger.new("db/#{ENV['ENV']}.log")
end
