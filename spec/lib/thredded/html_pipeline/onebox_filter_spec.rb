# frozen_string_literal: true

require 'spec_helper'

describe Thredded::HtmlPipeline::OneboxFilter do
  subject(:onebox_filter) { described_class.new(document, context) }

  let(:context) { nil }

  def find_singular_a_node(transformed)
    a_nodes = Nokogiri.HTML5(transformed).css('a[href]')
    expect(a_nodes.length).to eq(1)
    a_nodes.first
  end

  context 'with a link to an unsupported domain' do
    let(:document) do
      <<~HTML
      <!DOCTYPE html>
      <title>name</title>
      <body>
        <a href='#{href}'>#{href}</a>
      </body>
      HTML
    end
    let(:href) { 'https://www.example.com' }

    context 'with no context' do
      it 'generates a valid preview even for an unwhitelisted string' do
        transformed = onebox_filter.call
        a_node = find_singular_a_node(transformed)
        expect(a_node['href']).to eq(href)
        expect(a_node.text).to include(href)
      end
    end

    context 'with onebox_placeholders:true' do
      let(:context) { { onebox_placeholders: true } }

      it 'generates a valid preview even for an unwhitelisted string' do
        transformed = onebox_filter.call
        a_node = find_singular_a_node(transformed)
        expect(a_node['href']).to eq(href)
        expect(a_node.text).to include(href)
      end
    end
  end

  context 'with a strong link to an unsupported domain' do
    let(:document) do
      <<~HTML
      <!DOCTYPE html>
      <title>name</title>
      <body>
        <strong><a href='#{href}'>#{href}</a></strong>
      </body>
      HTML
    end
    let(:href) { 'https://www.example.com' }

    context 'with no context' do
      it 'generates a valid preview even for an unwhitelisted string' do
        transformed = onebox_filter.call
        a_node = find_singular_a_node(transformed)
        expect(a_node['href']).to eq(href)
        expect(a_node.text).to include(href)
      end
    end

    context 'with onebox_placeholders:true' do
      let(:context) { { onebox_placeholders: true } }

      it 'generates a valid preview even for an unwhitelisted string' do
        transformed = onebox_filter.call
        a_node = find_singular_a_node(transformed)
        expect(a_node['href']).to eq(href)
        expect(a_node.text).to include(href)
      end
    end
  end
end
