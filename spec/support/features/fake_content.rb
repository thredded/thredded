# frozen_string_literal: true
module FakeContent # rubocop:disable Metrics/ModuleLength
  module_function

  IMAGES = [
    ['Mario', 'https://storage.googleapis.com/glebm-stuff/mario.jpg'],
    ['This is fine', 'https://storage.googleapis.com/glebm-stuff/this-is-fine.jpg'],
    ['I want things to be different... oh no', 'https://storage.googleapis.com/glebm-stuff/webcomicname-different.jpg'],
  ].freeze

  YOUTUBE_VIDEO_IDS = %w(5lBBUPVuusM vDnpDgY_Im4 dQw4w9WgXcQ).freeze
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
    %q(Use the Euler's formula: $$e^{ \pm i\theta } = \cos \theta \pm i\sin \theta$$),
    <<~'TEX',
      This is the recurrence relation you need:

      \$$
      f(n) = \begin{cases} \frac{n}{2}, & \text{if } n\text{ is even} \\ 3n+1, & \text{if } n\text{ is odd} \end{cases}
      $$
    TEX
    <<~'TEX'
      Well, obviously:

      \$$
      f(x) = \int_{-\infty}^\infty\hat f(\xi)\,e^{2 \pi i \xi x}\,d\xi
      $$
    TEX
  ].freeze
  SMILEYS = %w(:smile: 💥).freeze

  def post_content # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength
    result = []

    result << Faker::Hacker.say_something_smart.split(' ').map do |word|
      next word unless rand < 0.05 || word.length < 4
      style = %w(* ** _).sample
      "#{style}#{word}#{style}"
    end.join(' ')

    result[0] += " #{SMILEYS.sample}" if rand < 0.1

    if rand < 0.1
      result << [
        'Check this out:',
        'Very relevant:',
        %q(You're gonna love this!),
      ].sample +  "\n\n" + "https://www.youtube.com/watch?v=#{YOUTUBE_VIDEO_IDS.sample}"
    end

    if rand < 0.07
      alt_text, url = IMAGES.sample
      result << "That feeling when:\n![#{alt_text}](#{url})"
    end

    result << FORMULAS.sample if rand < 0.05

    if rand < 0.03
      lang, source =  CODE_SNIPPETS.sample
      result << "Here is how:\n```#{lang}\n#{source.chomp}\n```"
    end

    if rand < 0.03
      result << <<~'MARKDOWN'
        The encryption algorithm at the heart of our enterprise-grade software is:

        | x | y | x ⊕ y |
        |---|---|:-----:|
        | 1 | 1 |   0   |
        | 1 | 0 |   1   |
        | 0 | 1 |   1   |
        | 0 | 0 |   0   |
      MARKDOWN
    end

    if rand < 0.1
      i = rand(result.length)
      result[i] = ["And then they said:\n", "So much this:\n"].sample +
                  result[i].split("\n").map { |line| ">#{' ' unless line.empty?}#{line}" }.join("\n")
    end

    result.shuffle!
    result.join("\n")
  end
end
