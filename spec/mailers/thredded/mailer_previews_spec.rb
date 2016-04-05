require 'spec_helper'

module Thredded
  describe 'Mailer previews' do
    [PostMailerPreview, PrivateTopicMailerPreview, PrivatePostMailerPreview].each do |preview_class|
      describe preview_class do
        preview_class.public_instance_methods(false).each do |method_name|
          describe "##{method_name}" do
            let(:mail) { preview_class.new.send(method_name) }

            it 'renders' do
              expect { mail.body }.to_not raise_exception
            end

            it 'does not create any records' do
              expect { mail }.to_not change {
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
