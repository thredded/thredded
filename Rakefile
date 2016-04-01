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

require 'rubocop/rake_task'
RuboCop::RakeTask.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task(:default).clear
task default: [:spec, :rubocop]

# Common methods for the test_all_dbs, test_all_gemfiles, and test_all Rake tasks.
module TestTasks
  module_function

  def run_all(envs, cmd = 'bundle install --quiet && bundle exec rspec', success_message:)
    statuses = envs.map { |env| run(env, cmd) }
    failed   = statuses.reject(&:first).map(&:last)
    if failed.empty?
      $stderr.puts success_message
    else
      $stderr.puts "❌  FAILING (#{failed.size}):\n#{failed.map { |env| to_bash_cmd_with_env(cmd, env) } * "\n"}"
      exit 1
    end
  end

  def run(env, cmd)
    require 'pty'
    require 'English'
    Bundler.with_clean_env do
      $stderr.puts to_bash_cmd_with_env(cmd, env)
      PTY.spawn(env, cmd) do |r, _w, pid|
        begin
          r.each_line { |l| puts l }
        rescue Errno::EIO
          # Errno:EIO error means that the process has finished giving output.
          next
        ensure
          ::Process.wait pid
        end
      end
      [$CHILD_STATUS && $CHILD_STATUS.exitstatus == 0, env]
    end
  end

  def gemfiles
    Dir.glob('./spec/gemfiles/*.gemfile').sort
  end

  def dbs
    %w(mysql2 postgresql)
  end

  def to_bash_cmd_with_env(cmd, env)
    "(export #{env.map { |k, v| "#{k}=#{v}" }.join(' ')}; #{cmd})"
  end
end

desc 'Test all Gemfiles from spec/*.gemfile'
task :test_all_gemfiles do
  envs = TestTasks.gemfiles.map { |gemfile| { 'BUNDLE_GEMFILE' => gemfile } }
  TestTasks.run_all envs, success_message: "✓ Tests pass with all #{envs.size} gemfiles"
end

desc 'Test all supported databases'
task :test_all_dbs do
  envs = TestTasks.dbs.map { |db| { 'DB' => db } }
  TestTasks.run_all envs, 'bundle exec rspec', success_message: "✓ Tests pass with all #{envs.size} databases"
end

desc 'Test all databases x gemfiles'
task :test_all do
  dbs      = TestTasks.dbs
  gemfiles = TestTasks.gemfiles
  TestTasks.run_all dbs.flat_map { |db| gemfiles.map { |gemfile| { 'DB' => db, 'BUNDLE_GEMFILE' => gemfile } } },
                    success_message: "✓ Tests pass with all #{dbs.size} databases x #{gemfiles.size} gemfiles"
end

Bundler::GemHelper.install_tasks

# Dump / load schema in all supported flavours
dbs = Array(ENV.fetch('DB', TestTasks.dbs))
schema_path   = -> db { "db/schema.#{db}.rb" }
connect_to_db = -> db { ActiveRecord::Base.establish_connection(ActiveRecord::Base.connection_config.merge(adapter: db)) }
namespace :db do
  namespace :schema do
    desc "Create #{dbs.map { |db| schema_path.call(db) }.to_sentence}"
    Rake::Task['db:schema:dump'].clear
    task dump: :environment do
      dbs.each do |db|
        connect_to_db.call(db)
        path = schema_path.call(db)
        puts "Create #{path}"
        File.open(File.expand_path(path, File.dirname(__FILE__)), 'w:utf-8') do |file|
          ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
        end
      end
    end
    desc dbs.map { |db| schema_path.call(db) }.to_sentence(two_words_connector: ' or ', last_word_connector: ', or ')
    task :load
    task set_env: :environment do
      ENV['SCHEMA'] = schema_path.call(ActiveRecord::Base.connection_config[:adapter])
      puts "Load #{ENV['SCHEMA']}"
    end
    Rake::Task['app:db:schema:load'].enhance(%w(db:schema:set_env))
  end

  desc 'Truncate all tables'
  task truncate: :environment do
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table} CASCADE;")
    end
  end
end

namespace :dev do
  desc 'Start development web server'
  task :server do
    require 'rails/commands/server'

    host = '0.0.0.0'
    port = ENV['PORT'] || 9292
    ENV['RACK_ENV'] = ENV['RAILS_ENV'] = 'development'
    Dir.chdir 'spec/dummy'

    Rack::Server.start(
      environment: 'development',
      Host: host,
      Port: port,
      config: 'config.ru'
    )
  end

  desc 'Seed DB for dummy app development'
  task seed: :environment do
    require 'thredded/seed_database'

    Thredded::SeedDatabase.run
  end
end
