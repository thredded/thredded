require 'thredded/tag_translater'

namespace :thredded do
  desc 'Migrate legacy [t:img] tags to embedded image tags (bbcode or markdown)'
  task update_legacy_timg_tags: :environment do
    Thredded::TagTranslater.replace_all_timg_tags
  end

  desc 'Destroy messageboard and all related data'
  task :destroy, [:slug] => :environment do |_, args|
    Thredded::MessageboardDestroyer.new(args.slug).run
  end

  task :nuke, [:slug] => :destroy
end
