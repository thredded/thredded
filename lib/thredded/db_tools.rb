# frozen_string_literal: true

module Thredded
  module DbTools
    class << self
      MIGRATION_SPEC_SOURCE_VERSION = 'v0.8'

      # Runs the migrations in the given paths.
      def migrate(paths:, quiet:, &filter)
        verbose_was = ActiveRecord::Migration.verbose
        ActiveRecord::Migration.verbose = !quiet
        migrate =
          if Rails.gem_version >= Gem::Version.new('6.0.0.rc2')
            -> { ActiveRecord::MigrationContext.new(paths, ActiveRecord::SchemaMigration).migrate(nil, &filter) }
          elsif Rails::VERSION::STRING >= '5.2'
            -> { ActiveRecord::MigrationContext.new(paths).migrate(nil, &filter) }
          else
            -> { ActiveRecord::Migrator.migrate(paths, &filter) }
          end
        if quiet
          silence_active_record(&migrate)
        else
          migrate.call
        end
      ensure
        ActiveRecord::Migration.verbose = verbose_was
      end

      def dump_file
        File.expand_path("../../../spec/migration/#{MIGRATION_SPEC_SOURCE_VERSION}.#{adapter}.dump", __FILE__)
      end

      def dump(to = dump_file)
        case adapter
        when /sqlite/i
          system ['sqlite3', Rails.root.join(database), '.dump', '>', to].join(' ')
        when /postgres/i
          cmd = "pg_dump --dbname=postgresql://#{username}:#{password}@#{host}:5432/#{database}" \
            "--verbose --clean --no-owner --no-acl --format=c > #{to}"
          system cmd
        when /mysql/i
          system("mysqldump --user #{username} -p#{password} #{database} > #{to}")
        end
      end

      def restore(from = dump_file)
        case adapter
        when /postgres/i
          cmd = [
            'pg_restore --verbose --clean --no-owner --no-acl',
            "--dbname=postgresql://#{username}:#{password}@#{host}:5432/#{database}",
            from,
            '>',
            Rails.root.join('log', 'restore.log')
          ].join(' ')
          system cmd
        when /mysql/i, /sqlite/i
          connection = ActiveRecord::Base.connection
          statements = File.read(from).split(/;$/)
          statements.pop
          silence_active_record do
            ActiveRecord::Base.transaction do
              statements.each do |statement|
                connection.execute(statement) unless statement =~ /(BEGIN TRANSACTION|COMMIT)/
              end
            end
          end
        end
      end

      def silence_active_record
        was = ActiveRecord::Base.logger.level
        ActiveRecord::Base.logger.level = Logger::WARN
        yield
      ensure
        ActiveRecord::Base.logger.level = was
      end

      def config
        @config ||= Rails.configuration.database_configuration[Rails.env]
      end

      def adapter
        config['adapter']
      end

      def database
        config['database']
      end

      def username
        config['username']
      end

      def password
        config['password']
      end

      def host
        config['host']
      end
    end
  end
end
