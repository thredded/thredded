# frozen_string_literal: true
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
    %w(sqlite3 mysql2 postgresql)
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
end

namespace :assets do
  desc 'Precompile assets within dummy app'
  task :precompile do
    Dir.chdir('spec/dummy') do
      system('bundle exec rake assets:precompile')
    end
  end
end
