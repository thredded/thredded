require 'spec_helper'
require 'thredded/tag_translater'

module Thredded
  describe TagTranslater, '#translate' do
    context 'for bbcode filtered posts' do
      it 'replaces a [t:img] tag with a bbcode tag' do
        post = create(:post, :bbcode, content: 'With img [t:img=1]')
        create(:attachment, post: post)

        TagTranslater.new(post).timg_to_image_tag
        post.reload

        expect(post.content).to eq 'With img [img]/uploads/attachment/1/img.png[/img]'
      end

      it 'replaces several [t:img] tags with bbcode tags' do
        post = create(:post, :bbcode, content: '[t:img=1] [t:img=2]')
        create(:txtpng, post: post)
        create(:pdfpng, post: post)

        TagTranslater.new(post).timg_to_image_tag
        post.reload

        expect(post.content).to eq '[img]/uploads/attachment/1/txt.png[/img] [img]/uploads/attachment/2/pdf.png[/img]'
      end
    end

    context 'for markdown filtered posts' do
      it 'replaces [t:img] with a markdown image tag' do
        post = create(:post, :markdown, content: 'img [t:img=1]')
        create(:attachment, post: post)

        TagTranslater.new(post).timg_to_image_tag
        post.reload

        expect(post.content)
          .to eq 'img ![](/uploads/attachment/1/img.png)'
      end

      it 'replaces several [t:img] tags with markdown tags' do
        post = create(:post, :markdown, content: '[t:img=1] [t:img=2]')
        create(:txtpng, post: post)
        create(:pdfpng, post: post)

        TagTranslater.new(post).timg_to_image_tag
        post.reload

        expect(post.content).to eq '![](/uploads/attachment/1/txt.png) ![](/uploads/attachment/2/pdf.png)'
      end
    end
  end
end
