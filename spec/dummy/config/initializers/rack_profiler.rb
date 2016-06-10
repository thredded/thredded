if Rails.env.development?
  require 'rack-mini-profiler'
  Rack::MiniProfilerRails.initialize!(Rails.application)
  Rack::MiniProfiler.config.tap do |c|
    c.backtrace_remove = Thredded::Engine.root.to_s
    c.backtrace_includes = [/^\/?(app|config|lib|spec)/]
  end
end
