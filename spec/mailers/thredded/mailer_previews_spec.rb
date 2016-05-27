# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe 'Mailer previews' do
    [PostMailerPreview, PrivateTopicMailerPreview].each do |preview_class|
      describe preview_class do
        preview_class.public_instance_methods(false).each do |method_name|
          describe "##{method_name}" do
            let(:mail) { preview_class.new.send(method_name) }

            it 'renders' do
              expect { mail.body }.not_to raise_exception
            end

            it 'does not create any records' do
              expect { mail }.not_to change {
                [Messageboard.count, Topic.count, Post.count, PrivateTopic.count, PrivatePost.count,
                 Thredded.user_class.count, UserDetail.count, MessageboardUser.count]
              }
            end
          end
        end
      end
    end
  end
end
