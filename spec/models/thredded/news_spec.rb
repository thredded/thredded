# frozen_string_literal: true

require 'spec_helper'

module Thredded

  describe News do

    it 'finds the news by id' do
      news = create(:news, id: 1, title: 'New news')
      expect(News.find!(1)).to eq news
    end

    it 'raises Thredded::Errors::NewsNotFound error' do
      expect { News.find!('2') }
          .to raise_error(Thredded::Errors::NewsNotFound)
    end

    it 'news without title not valid' do
      news = create(:news, id: 1, title: 'test news')
      news.title = nil
      expect(news).to_not be_valid
    end

    it 'attaches jpeg file to the news_banner' do
      file = fixture_file_upload(Rails.root.join('public', 'apple-touch-icon.jpeg'))
      news = create(:news, title: 'new news', news_banner: file)
      expect(news.news_banner).to be_attached
    end

    it 'raises ActiveRecord::RecordInvalid error' do
      file = fixture_file_upload(Rails.root.join('public', 'apple-touch-icon.png'))
      expect { create(:news, title: 'new news', news_banner: file) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'not attaching oversized jpeg file to the news_banner' do
      file = fixture_file_upload(Rails.root.join('public', 'oversize_test_image.jpg'))
      expect { create(:news, title: 'new news', news_banner: file) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

end