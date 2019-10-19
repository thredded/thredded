# frozen_string_literal: true

require 'pathname'
require 'set'

module Thredded
  # Lets you include Thredded JavaScripts into your Webpack "pack".
  #
  # To use this, first run `bundle exec rails webpacker:install:erb`.
  # Then, rename `app/javascript/packs/application.js` to `app/javascript/packs/application.js.erb`
  # Finally, add this line to `app/javascript/packs/application.js.erb`:
  #
  # <%= Thredded::WebpackAssets.javascripts %>
  #
  # To include additional timeago locales, add this *before* `Thredded::WebpackAssets.javascripts`:
  #
  # <% timeago_root = File.join(Gem.loaded_specs['timeago_js'].full_gem_path, 'assets', 'javascripts') %>
  #   import "<%= File.join(timeago_root, 'timeago.js') %>";
  # <%= %w[de pt_BR].map { |locale| %(import "#{File.join(timeago_root, "timeago/locales/#{locale}.js")}";) } * "\n" %>
  module WebpackAssets
    JAVASCRIPT_EXTS = %w[.es6 .js].freeze

    def self.javascripts
      @javascripts ||= JavaScriptsResolver.new.resolve('thredded.es6')
    end

    class JavaScriptsResolver
      def resolve(entry_point)
        resolve_full_paths(entry_point).map do |dep|
          %(import "#{dep}";)
        end.join("\n")
      end

      private

      def resolve_full_paths(entry_point)
        deps = []
        seen = Set.new
        queue = [[:start, dep_to_path(entry_point)]]
        until queue.empty?
          state, path = queue.pop
          if state == :visiting
            deps << path
            next
          end
          next unless seen.add?(path)
          queue << [:visiting, path]
          next if path.to_s.start_with?('@')
          src = File.read(path)
          src.scan(%r{//= require (\S+)}).each do |m|
            queue << [:start, dep_to_path(m[0])]
          end
          tree_root = Pathname.new(File.dirname(path))
          src.scan(%r{//= require_tree (\S+)}).each do |m|
            tree_root.join(m[0]).each_child do |pn|
              next unless JAVASCRIPT_EXTS.include?(pn.extname)
              queue << [:start, pn.cleanpath.to_s]
            end
          end
        end
        deps
      end

      def engine_js_root
        @engine_js_root ||= Pathname.new(engine_js_prefix)
      end

      def engine_js_prefix
        @engine_js_prefix ||=
          File.expand_path('app/assets/javascripts', File.join(__dir__, '../..'))
      end

      def engine_vendor_js_prefix
        @engine_vendor_js_prefix ||=
          File.expand_path('vendor/assets/javascripts', File.join(__dir__, '../..'))
      end

      def engine_dep?(dep)
        dep.start_with?('thredded/')
      end

      def engine_dep_to_path(dep)
        find_dep_in_path(engine_js_prefix, dep) ||
          find_dep_in_path(engine_vendor_js_prefix, dep) ||
          fail("Failed to find #{dep}")
      end

      def find_dep_in_path(dir, dep)
        path = File.join(dir, dep)
        return path if File.file?(path)
        JAVASCRIPT_EXTS.each do |ext|
          path_with_ext = "#{path}#{ext}"
          return path_with_ext if File.file?(path_with_ext)
        end
        nil
      end

      def dep_to_path(dep)
        if dep == 'timeago'
          path = File.join(Gem.loaded_specs['timeago_js'].full_gem_path, 'assets', 'javascripts', "#{dep}.js")
          fail "Failed to find #{dep}" unless File.file?(path)
          return path
        elsif dep == 'rails-ujs'
          return '@rails/ujs'
        end
        engine_dep_to_path(dep)
      end
    end
  end
end
