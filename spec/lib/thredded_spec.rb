require 'spec_helper'

describe Thredded, '.user_path' do
  after do
    Thredded.user_path = nil
  end

  it 'returns "/" if lambda is not set' do
    expect(Thredded.user_path(nil)).to eq '/'
  end

  context 'lambda is created and called with a user' do
    it 'returns one path' do
      me = build_stubbed(:user, name: 'joel')
      Thredded.user_path = ->(user){ "/my/name/is/#{user}" }

      expect(Thredded.user_path(me)).to eq '/my/name/is/joel'
    end

    it 'returns another path' do
      you = build_stubbed(:user, name: 'carl')
      Thredded.user_path = ->(user){ "/wow/so/#{user}" }

      expect(Thredded.user_path(you)).to eq '/wow/so/carl'
    end
  end
end
