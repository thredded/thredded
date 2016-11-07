# frozen_string_literal: true
namespace :thredded do
  namespace :install do
    desc 'Copy emoji to the Rails `public/emoji` directory'
    task :emoji do
      require 'emoji'

      target = Rails.application.root.join('public')
      STDERR.puts "Copying emoji to #{target}"
      `mkdir -p '#{target}' && cp -Rp '#{Emoji.images_path}/emoji' '#{target}'`
    end
  end
end
