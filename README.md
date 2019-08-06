# Rapture

A Ruby library for [Discord](https://discord.com).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'discord-rapture'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install discord-rapture

## Usage

```ruby
require 'rapture'

client = Rapture::Client.new("Bot Y0UR.T0KEN.HERE")

client.on_message_create do |message|
  if message.content.start_with? '!ping'
    bot.create_message(message.channel_id, content: 'Pong!')
  end
end

bot.run
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/z64/rapture.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
