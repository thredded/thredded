require 'spec_helper'

RSpec.describe 'partial: thredded/shared/time_ago' do
  def render_partial(datetime)
    render partial: 'thredded/shared/time_ago', locals: { datetime: datetime }
  end

  it 'renders a datetime' do
    render_partial Chronic.parse('March 1, 2015 at noon')
    expect(rendered).to eq(<<-HTML.strip_heredoc)
      <abbr class="timeago" title="2015-03-01T12:00:00Z">
        2015-03-01 12:00:00 UTC
      </abbr>
    HTML
  end

  it 'with nil, something ambiguous' do
    render_partial nil
    expect(rendered).to eq <<-HTML.strip_heredoc
      <abbr>a little while ago</abbr>
    HTML
  end
end
