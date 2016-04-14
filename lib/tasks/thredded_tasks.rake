# frozen_string_literal: true
namespace :thredded do
  desc 'Destroy messageboard and all related data'
  task :destroy, [:slug] => :environment do |_, args|
    Thredded::MessageboardDestroyer.new(args.slug).run
  end

  task :nuke, [:slug] => :destroy

  namespace :install do
    desc 'Copy emoji to the Rails `public/emoji` directory'
    task :emoji do
      require 'emoji'

      target = "#{Rake.original_dir}/public"
      `mkdir -p '#{target}' && cp -Rp '#{Emoji.images_path}/emoji' '#{target}'`
    end
  end
end
