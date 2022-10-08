# frozen_string_literal: true

require 'spec_helper'
Rails.env = 'test'
# To run this individual configuration specs, run:
# CONFIGURATION_SPEC=1 bundle exec rspec spec/configuration/with_rails_routes_included_in_application_helper_spec.rb
# To run all configuration specs, run:
# spec/configuration/run_all
RSpec.feature 'Configuration: With rails.routes.url_helpers included in application_helper', configuration_spec: true do
  before(:all) do
    # This is the configuration change we're making on the dummy
    ::ApplicationHelper.include Rails.application.routes.url_helpers
  end

  let(:user) { create(:user, name: 'Not a Faker username') }
  let(:messageboard) { create(:messageboard) }
  let(:topic) { create(:topic, messageboard: messageboard) }
  let(:topic_page) { PageObject::Topic.new(topic) }
  let!(:first_post) { create(:post, postable: topic) }

  before do
    PageObject::User.new(user).log_in
  end

  specify 'the user can visit the topic' do
    topic_page.visit_topic
  end
end
