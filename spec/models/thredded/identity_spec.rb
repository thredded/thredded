require 'spec_helper'

describe Identity, 'associations' do
  it { should belong_to(:user) }
end

describe Identity, '#from_omniauth' do
  let(:auth_github) {
    {
      'provider' => 'github',
      'uid' => '123',
      'info' => {
        'nickname' => 'jayroh',
        'email' => 'joel@example.com',
      }
    }
  }

  context 'Via github' do
    it 'for a new user creates an identity and user' do
      identity = Identity.from_omniauth( auth_github )

      identity.should be_persisted
      identity.should be_valid
      identity.user.name.should eq 'jayroh'
      identity.user.email.should eq 'joel@example.com'
    end

    it 'for new identity and user creates them both' do
      user = create(:user, name: 'joel', email: 'joel@example.com')
      identity = Identity.from_omniauth( auth_github )

      identity.should be_persisted
      identity.should be_valid
      identity.user.should eq user
    end

    it 'uses an existing identity and user' do
      user = create(:user, name: 'joel', email: 'joel@example.com')
      previous_identity = create(:identity, uid: '123',
                                 provider: 'github', user: user)
      identity = Identity.from_omniauth( auth_github )

      identity.should eq previous_identity
      identity.user.should eq user
    end
  end
end
