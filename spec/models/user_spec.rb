require 'spec_helper'

describe User, 'associations' do
  it { should have_many(:thredded_messageboard_preferences) }
  it { should have_many(:thredded_posts) }
  it { should have_many(:thredded_private_topics) }
  it { should have_many(:thredded_private_users) }
  it { should have_many(:thredded_roles) }
  it { should have_many(:thredded_topics) }

  it { should have_one(:thredded_user_detail) }
  it { should have_one(:thredded_user_preference) }
end

describe User, '.recently_active_in' do
  it 'returns users who were active as of 5 minutes ago' do
    messageboard = create(:messageboard)
    phil = create(:role, :inactive, messageboard: messageboard)
    tom = create(:role, messageboard: messageboard, last_seen: 1.minute.ago)
    joel = create(:role, messageboard: messageboard, last_seen: 2.minutes.ago)

    active_users = User.recently_active_in(messageboard)

    expect(active_users).to include(joel.user)
    expect(active_users).to include(tom.user)
    expect(active_users).not_to include(phil.user)
  end
end

describe User, '.to_s' do
  it 'returns the username string' do
    user = create(:user, name: 'Joseph')

    expect(user.to_s).to eq 'Joseph'
  end
end
