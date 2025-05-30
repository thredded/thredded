# frozen_string_literal: true

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

APP_RAKEFILE = File.expand_path('spec/dummy/Rakefile', __dir__)
load 'rails/tasks/engine.rake'
namespace :webpacker do
  desc 'Install test app deps with yarn'
  task :yarn_install do
    Dir.chdir(File.join(__dir__, 'spec/dummy')) do
      system 'yarn install --no-progress --production'
    end
  end

  desc 'Compile test app JavaScript packs using webpack for production with digests'
  task compile: %i[yarn_install load_app] do
    Dir.chdir(File.join(__dir__, 'spec/dummy')) do
      Webpacker.with_node_env('production') do
        Webpacker.ensure_log_goes_to_stdout do
          exit! unless ::Webpacker.instance.commands.compile
        end
      end
    end
  end
end

# Common methods for the test_all_dbs, test_all_gemfiles, and test_all Rake tasks.
module TestTasks
  module_function

  TEST_CMD = 'bundle exec rspec'

  def run_all(envs, cmd = "bundle install --quiet && #{TEST_CMD}", success_message:)
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
        r.each_line { |l| puts l }
      rescue Errno::EIO
        # Errno:EIO error means that the process has finished giving output.
        next
      ensure
        ::Process.wait pid
      end
      [$CHILD_STATUS&.exitstatus&.zero?, env]
    end
  end

  def gemfiles
    Dir.glob('./spec/gemfiles/rails_*.gemfile').sort
  end

  def dbs
    %w[sqlite3 mysql2 postgresql]
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
  TestTasks.run_all envs, TestTasks::TEST_CMD, success_message: "✓ Tests pass with all #{envs.size} databases"
end

desc 'Test all databases x gemfiles'
task :test_all do
  dbs      = TestTasks.dbs
  gemfiles = TestTasks.gemfiles
  TestTasks.run_all dbs.flat_map { |db| gemfiles.map { |gemfile| { 'DB' => db, 'BUNDLE_GEMFILE' => gemfile } } },
                    success_message: "✓ Tests pass with all #{dbs.size} databases x #{gemfiles.size} gemfiles"
end

Bundler::GemHelper.install_tasks

namespace :dev do
  desc 'Start development web server'
  task :server do
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
end

namespace :assets do
  desc 'Precompile assets within dummy app'
  task precompile: 'app:assets:precompile'

  desc 'Remove old compiled assets from dummy app'
  task clean: 'app:assets:clean'
end

if ENV['HEROKU']
  require 'rollbar/rake_tasks'
elsif !ENV['CI']
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new

  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)

  task(:default).clear
  task default: %i[spec rubocop]
end

namespace :db do
  desc "Wipe out all tables' data"
  task truncate: :environment do
    connection = ActiveRecord::Base.connection
    tables = connection.tables - %w[schema_migrations]

    tables.each do |table|
      case connection.adapter_name
      when /sqlite/i
        connection.execute("DELETE FROM #{table}")
        connection.execute("DELETE FROM sqlite_sequence where name='#{table}'")
      when /mysql/i
        connection.execute("DELETE FROM #{table}")
      when /postgres/i
        connection.execute("TRUNCATE #{table} CASCADE")
      end
    end
  end

  desc 'Re-seed database with new data'
  task reseed: %i[truncate seed]

  desc 'do a mini seed to generate sample data for migration tests'
  task miniseed: :environment do
    require 'thredded/database_seeder'
    Thredded::DatabaseSeeder.run(users: 5, topics: 5, posts: 1..5)
  end

  task miniseed_dump: [:miniseed] do
    require 'thredded/db_tools'
    Thredded::DbTools.dump
    system('cd spec/dummy && rails db:environment:set RAILS_ENV=development')
  end
end
