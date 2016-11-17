# frozen_string_literal: true
module Thredded
  module DbTools
    class << self
      MIGRATION_SPEC_SOURCE_VERSION = 'v0.8'

      def dump_file
        File.expand_path("../../../spec/migration/#{MIGRATION_SPEC_SOURCE_VERSION}.#{adapter}.dump", __FILE__)
      end

      def dump(to = dump_file)
        case adapter
        when /sqlite/i
          system "sqlite3 #{Rails.root.join(database)} .dump > #{to}"
        when /postgres/i
          cmd = "pg_dump --host #{host} --username #{username} --verbose --clean --no-owner --no-acl --format=c " \
            "#{database} > #{to}"
          system cmd
        when /mysql/i
          system("mysqldump --user #{username} -p#{password} #{database} > #{to}")
        end
      end

      def restore(from = dump_file)
        case adapter
        when /postgres/i
          cmd = [
            'pg_restore --verbose'" --host #{host}",
            "--username #{username}",
            ' --clean --no-owner --no-acl ',
            " --dbname #{database} #{from}",
            " > #{Rails.root.join('log/restore.log')}"
          ].join(' ')
          system cmd
        when /mysql/i, /sqlite/i
          connection = ActiveRecord::Base.connection
          statements = File.read(from).split(/;$/)
          statements.pop
          ActiveRecord::Base.transaction do
            statements.each do |statement|
              connection.execute(statement) unless statement =~ /(BEGIN TRANSACTION|COMMIT)/
            end
          end
        end
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
