require 'spec_helper'

describe User, 'associations' do
  it { should have_many(:thredded_messageboard_preferences) }
  it { should have_many(:thredded_posts) }
  it { should have_many(:thredded_private_topics) }
  it { should have_many(:thredded_private_users) }
  it { should have_many(:thredded_roles) }
  it { should have_many(:thredded_messageboards).through(:thredded_roles) }
  it { should have_many(:thredded_topics) }

  it { should have_one(:thredded_user_detail) }
  it { should have_one(:thredded_user_preference) }
end

describe User, '.to_s' do
  it 'returns the username string' do
    user = create(:user, name: 'Joseph')

    expect(user.to_s).to eq 'Joseph'
  end
end
