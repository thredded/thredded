require 'spec_helper'

describe Thredded, '.queue_backend' do
  it 'defaults the queue backend to in memory' do
    expect(Thredded.queue_backend).to eq :threaded_in_memory_queue
  end

  it 'allows the queue backend to change' do
    Thredded.queue_backend = :resque

    expect(Thredded.queue_backend).to eq :resque
  end
end

describe Thredded, '.queue_memory_log_level' do
  after do
    Thredded.queue_memory_log_level = Logger::WARN
  end

  it 'defaults the threaded memory log level' do
    expect(Thredded.queue_memory_log_level).to eq Logger::WARN
  end

  it 'allows the threaded memory log level to change' do
    Thredded.queue_memory_log_level = Logger::INFO

    expect(Thredded.queue_memory_log_level).to eq Logger::INFO
  end
end

describe Thredded, '.user_path' do
  it 'returns "/" if lambda is not set' do
    Thredded.user_path = nil
    expect(Thredded.user_path(_view_context = nil, _user = nil)).to eq '/'
  end

  context 'lambda is created and called with a user' do
    it 'returns one path' do
      me = build_stubbed(:user, name: 'joel')
      Thredded.user_path = ->(user) { "/my/name/is/#{user}" }
      expect(Thredded.user_path(_view_context = nil, _user = me)).to eq '/my/name/is/joel'
    end

    it 'returns another path' do
      you = build_stubbed(:user, name: 'carl')
      Thredded.user_path = ->(user) { "/wow/so/#{user}" }
      expect(Thredded.user_path(_view_context = nil, _user = you)).to eq '/wow/so/carl'
    end

    it 'executes in the given context' do
      Thredded.user_path = ->(_user) { reverse }
      expect(Thredded.user_path(_view_context = 'abc', _user = nil)).to eq 'cba'
    end
  end
end
