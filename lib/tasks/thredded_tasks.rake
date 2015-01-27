namespace :thredded do
  desc 'Assign thredded superadmin status to a user'
  task :superadmin, [:username] => :environment do |_, args|
    Thredded::AuthorizeSuperadmin.new(args.username).run
  end

  desc 'Destroy messageboard and all related data'
  task :destroy, [:slug] => :environment do |_, args|
    Thredded::MessageboardDestroyer.new(args.slug).run
  end

  task :nuke, [:slug] => :destroy
end
