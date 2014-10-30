#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

begin
  require 'rdoc/task'
rescue LoadError
  require 'rdoc/rdoc'
  require 'rake/rdoctask'
  RDoc::Task = Rake::RDocTask
end

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Thredded'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

APP_RAKEFILE = File.expand_path('../spec/dummy/Rakefile', __FILE__)
load 'rails/tasks/engine.rake'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task default: :spec

Bundler::GemHelper.install_tasks

# Dump / load schema in all supported flavours
supported_dbs = %w(mysql2 postgresql)
schema_path   = -> db { "db/schema.#{db}.rb" }
connect_to_db = -> db {
  ActiveRecord::Base.establish_connection(ActiveRecord::Base.connection_config.merge(adapter: db))
}
namespace :db do
  namespace :schema do
    desc "Create #{supported_dbs.map { |db| schema_path.(db) }.to_sentence}"
    Rake::Task['db:schema:dump'].clear
    task :dump => :environment do
      supported_dbs.each do |db|
        connect_to_db.(db)
        path = schema_path.(db)
        puts "Create #{path}"
        File.open(File.expand_path(path, File.dirname(__FILE__)), 'w:utf-8') do |file|
          ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
        end
      end
    end
    desc supported_dbs.map { |db| schema_path.(db) }.to_sentence(two_words_connector: ' or ', last_word_connector: ', or ')
    task :load
    task :set_env => :environment do
      ENV['SCHEMA'] = schema_path.(ActiveRecord::Base.connection_config[:adapter])
      puts "Load #{ENV['SCHEMA']}"
    end
    Rake::Task['app:db:schema:load'].enhance(%w(db:schema:set_env))
  end
end
