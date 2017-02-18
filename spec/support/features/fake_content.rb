# frozen_string_literal: true
module FakeContent # rubocop:disable Metrics/ModuleLength
  module_function

  IMAGES = [
    <<~MARKDOWN,
      Art:
      ![Mario](https://storage.googleapis.com/glebm-stuff/mario.jpg)
    MARKDOWN
    <<~MARKDOWN,
      ![This is fine](https://storage.googleapis.com/glebm-stuff/this-is-fine.jpg){:width="359px" height="170px"}
    MARKDOWN
    <<~MARKDOWN,
      That feeling when:
      ![I want things to be different... oh no](https://storage.googleapis.com/glebm-stuff/webcomicname-different.jpg)
    MARKDOWN
    <<~MARKDOWN,
      This is what we've done:
      ![XKCD 927: How standards proliferate](https://imgs.xkcd.com/comics/standards.png)
    MARKDOWN
    <<~MARKDOWN,
      ![nyancat](https://storage.googleapis.com/glebm-stuff/nyancat.gif)
    MARKDOWN
  ].freeze

  YOUTUBE_VIDEO_IDS = %w(5lBBUPVuusM vDnpDgY_Im4 dQw4w9WgXcQ wZZ7oFKsKzY WrO9PTpuSSs d-diB65scQU).freeze
  CODE_SNIPPETS = [
    ['js', <<~'JAVASCRIPT'],
      // Substitution combinator
      const S = a => b => c => a(c)(b(c));
    JAVASCRIPT
    ['ruby', <<~'RUBY'],
        y = -> generator {
        -> x {
          -> *args {
            generator.call(x.call(x)).call(*args)
          }
        }.call(-> x {
          -> *args {
            generator.call(x.call(x)).call(*args)
          }
        })
      }
    RUBY
    ['sass', <<~'SASS']
      @supports (flex-wrap: wrap)
        +thredded-media-desktop-and-up
          $item-border-width: 1px
          $item-padding-x: ($thredded-base-spacing * 0.8)
          $item-padding-y: $thredded-base-spacing
          .thredded--messageboards-group
            display: flex
            flex-direction: row
            flex-wrap: wrap
            justify-content: space-between
            margin-left: $item-border-width
            &::after
              content: ""
              margin-right: $item-border-width
              padding: 0 $item-padding-x
          .thredded--messageboard,
          .thredded--messageboards-group::after
            flex-basis: $thredded-messageboards-grid-item-flex-basis
            flex-grow: 1
          .thredded--messageboard
            margin-left: -$item-border-width
            padding: $item-padding-y $item-padding-x
    SASS
  ].freeze
  FORMULAS = [
    %q(Use the Euler's formula: $$e^{ \pm i\theta } = \cos \theta \pm i\sin \theta$$.),
    <<~'TEX',
      This is the recurrence relation you need:

      \$$
      f(n) = \begin{cases} \frac{n}{2}, & \text{if } n\text{ is even} \\ 3n+1, & \text{if } n\text{ is odd} \end{cases}
      $$
    TEX
    <<~'TEX'
      Therefore:

      \$$
      f(x) = \int_{-\infty}^\infty\hat f(\xi)\,e^{2 \pi i \xi x}\,d\xi
      $$
    TEX
  ].freeze
  SMILEYS = %w(:smile: :boom:).freeze

  def post_content(with_everything: false) # rubocop:disable Metrics/CyclomaticComplexity
    with_smiley = with_everything || rand < 0.1
    with_youtube = with_everything || rand < 0.05
    with_image = with_everything || rand < 0.07
    with_formula = with_everything || rand < 0.05
    with_code_snippet = with_everything || rand < 0.03
    with_markdown_table = with_everything || rand < 0.02
    with_quote = with_everything || rand < 0.08

    result = []

    result << styled_smart_thing(with_smiley: with_smiley)

    result << youtube_reference if with_youtube

    result << IMAGES.sample if with_image

    result << FORMULAS.sample if with_formula

    result << code_snippet if with_code_snippet

    result << markdown_table if with_markdown_table

    # Randomly quote a piece
    if with_quote
      i = rand(result.length)
      result[i] = [
        ['And then they said:', 'So much this:'].sample,
        *result[i].split("\n").map { |line| ">#{' ' unless line.empty?}#{line}" },
      ].join("\n") + "\n"
    end

    result.shuffle!
    result.join("\n")
  end

  def styled_smart_thing(with_smiley:)
    results = Faker::Hacker.say_something_smart.split(' ').map do |word|
      next word unless rand < 0.05 && word.length >= 4
      style = %w(* ** _).sample
      "#{style}#{word}#{style}"
    end
    results << " #{SMILEYS.sample}" if with_smiley
    results.join(' ')
  end

  def youtube_reference
    [
      'Check this out:',
      'Very relevant:',
      'Must see:',
      "You're gonna love this!",
    ].sample + "\n\n" + "https://www.youtube.com/watch?v=#{YOUTUBE_VIDEO_IDS.sample}"
  end

  def code_snippet
    lang, source = CODE_SNIPPETS.sample
    "Here is how:\n```#{lang}\n#{source.chomp}\n```"
  end

  def markdown_table
    <<~'MARKDOWN'
      The encryption algorithm at the heart of our enterprise-grade software is:

      | x | y | x ⊕ y |
      |---|---|:-----:|
      | 1 | 1 |   0   |
      | 1 | 0 |   1   |
      | 0 | 1 |   1   |
      | 0 | 0 |   0   |

    MARKDOWN
  end
end
