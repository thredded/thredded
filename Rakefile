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

if %w(development test).include? Rails.env
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new

  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)

  task(:default).clear
  task default: [:spec, :rubocop]

  desc 'Test all Gemfiles from spec/*.gemfile'
  task :test_all_gemfiles do
    require 'pty'
    require 'shellwords'
    require 'English'
    cmd      = 'bundle update --quiet && bundle exec rake --trace'
    statuses = Dir.glob('./spec/gemfiles/*.gemfile').sort.map do |gemfile|
      Bundler.with_clean_env do
        env = { 'BUNDLE_GEMFILE' => gemfile }
        $stderr.puts "Testing #{File.basename(gemfile)}:"
        $stderr.puts "  export BUNDLE_GEMFILE=#{gemfile}"
        $stderr.puts "  #{cmd}"
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
        [$CHILD_STATUS && $CHILD_STATUS.exitstatus == 0, gemfile]
      end
    end
    failed = statuses.reject(&:first).map(&:last)
    if failed.empty?
      $stderr.puts "✓ Tests pass with all #{statuses.size} gemfiles"
    else
      $stderr.puts "❌ FAILING #{failed * "\n"}"
      exit 1
    end
  end
end

Bundler::GemHelper.install_tasks

# Dump / load schema in all supported flavours
dbs = Array(ENV.fetch('DB', %w(mysql2 postgresql)))
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
