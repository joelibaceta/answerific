# Answerific

Mining bot that can answer natural language questions by mining the web.

**Note.** The accuracy of the bot (number of relevant answers) is fairly low right now.

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

```ruby
# Initialize a new Miner object
miner = Answerific::Miner.new()

# And ask it to answer questions

miner.answer 'what is the composition of Pluto?'
=> "scientists believe pluto is made mostly of rock and ice, but they will not be sure until more research is done"

miner.answer 'what is a fixie bike?'
=> "the fixies or fixed gears bicycles, in english, are gear bikes or fixed gear"

miner.answer 'who is Jane Austen?'
=> "Jane Austen is more than just a feminist"

miner.answer 'where is Montreal located?'
=> "montreal is a city/town with a large population in the province of quebec, canada which is located in the continent/region of north america"
```

## How it works

Given an input, answerific will

1. Preprocess the input
2. Detect the type of question
3. Parse and rearrange the input given the type of question
4. Extract information from the web for that parsed input
5. Select and return the best answer

## Roadmap

* [ ] Improve accuracy of the answers
* [ ] Add options at initialization
* [ ] Better support for wh-words (atm, the bot just gets rid of them)
* [ ] Better support for yes-no questions: answer with definite yes-no instead of statement

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/answerific/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
