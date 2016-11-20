# Place this file into lib/dependencies_logger.rb and require it from application.rb after Bundler.require as:
# require_relative '../lib/dependencies_logger'

require 'active_support/dependencies'

class DependenciesLogger
  def initialize
    @need_newline = false
    @load_depth = 0
  end

  def start_load(path, call:)
    STDERR.write indent @load_depth * 2,
                "#{"\n" if @need_newline}(#{call} #{short_path(path).inspect}"
    STDERR.flush
    @load_depth += 1
    @need_newline = true
  end

  def end_load(path, call:, result:)
    STDERR.puts indent (@need_newline ? 1 : @load_depth * 2), "#{result})"
    @load_depth -= 1
    @need_newline = false
  end

  def new_constants(new_constants)
    return if new_constants.empty?
    STDERR.puts indent @load_depth * 2,
                       "#{"\n" if @need_newline}(+ #{new_constants.join(' ')})"
    @need_newline = false
  end

  private

  def watch_stack_depth
    watch_stack.instance_variable_get(:@watching).size
  end

  # @return [ActiveSupport::Dependencies::WatchStack]
  def watch_stack
    ActiveSupport::Dependencies.constant_watch_stack
  end

  def short_path(path)
    if defined?(Rails) && Rails.app_class &&
        Rails.app_class.instance_variable_get(:@instance) &&
        path.start_with?(Rails.root.to_s)
      path[Rails.root.to_s.size + 1..-1]
    elsif path.start_with?(ENV['HOME'])
      "~#{path[ENV['HOME'].size..-1]}"
    else
      path
    end
  end

  def indent(n, s)
    s.gsub(/^/, ' ' * n)
  end

  class << self
    attr_reader :instance
  end
  @instance = new
end

ActiveSupport::Dependencies.singleton_class.prepend(Module.new do
  def load_file(path, *)
    DependenciesLogger.instance.start_load path, call: :load_file
    super.tap do |result|
      DependenciesLogger.instance.end_load(
          path, call: :load_file, result: result)
    end
  rescue Exception => e
    DependenciesLogger.instance.end_load path, call: :require, result: e.class
    raise e
  end
end)

Object.prepend(Module.new do
  def load(path, *)
    DependenciesLogger.instance.start_load path, call: :load
    super.tap do |result|
      DependenciesLogger.instance.end_load path, call: :load, result: result
    end
  rescue Exception => e
    DependenciesLogger.instance.end_load path, call: :require, result: e.class
    raise e
  end

  def require(path, *)
    DependenciesLogger.instance.start_load path, call: :require
    super.tap do |result|
      DependenciesLogger.instance.end_load path, call: :require, result: result
    end
  rescue Exception => e
    DependenciesLogger.instance.end_load path, call: :require, result: e.class
    raise e
  end
end)

ActiveSupport::Dependencies::WatchStack.prepend(Module.new do
  def new_constants
    super.tap do |result|
      DependenciesLogger.instance.new_constants(result)
    end
  end
end)
