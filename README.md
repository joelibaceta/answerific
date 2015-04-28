# Answerific

AI Bot that can answer questions posed in natural language.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'answerific'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install answerific

## Usage

WIP. Will be something like

    bot = Answerific::Bot.new()
    bot.answer('what is the composition of Pluto?')

## How it works

Given an input, answerific will

1. Preprocess the input
2. Detect the type of question (broad classes: wh - *what is...* - or declarative - *tell me ...*)
3. Parse and rearrange the input given the type of question
4. Extract information from the web for that parsed input
5. Select and return the best answer

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/answerific/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
