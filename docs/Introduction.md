# @title Introduction

# Rapture

## What is Rapture?

Rapture is a gem for interacting with the Discord API. It does its best
to have full API coverage and name methods and classes in a way that allows for the official API documentation to complement its own. Any object in the official documentation is also supported in Rapture.

## Why Rapture over Discordrb?

**Compared to Discordrb, Rapture**:

- Is more closely mapped to official documentation
- Is lower level library, you get the most out of it from reading official
  documentation.
- Operates on the principal of least surprise for most user facing methods.
- Has stateful rate limiting, including bucketing logic
- Has a stateless client as default
- Has the option to configure custom caches
- Recieves updates quickly
- You want a finer control over internal workings

**Discordrb might be better suited to you if**:

- You are a beginner to the Discord API
- You want a more established library with higher level abstractions
- You want easy omniauth support
- You need a library with voice send support (However Rapture voice send is on the way)



## Installation

The recommended method of installing Rapture is by adding it to your Gemfile

```ruby
source "https://rubygems.org"

gem "rapture"
```

However, you can install Rapture using `gem` as well.

### Windows Specific Instructions

Due to issues with `eventmachine` on ruby versions >2.3 the only way to install Rapture is with the following commands

```
gem install rapture
gem uninstall eventmachine
gem install eventmachine --platform ruby
```



## Example Bot

This is currently the most basic example of a bot that responds to a ping command.

```ruby

require "rapture"

client = Rapture::Client.new("Bot YOUR_TOKEN_HERE")

client.on_message_create do |message|
  if message.content.start_with? "!ping"
    client.create_message(message.channel_id, content: "pong!")
  end
end

```

## Using custom caches

See [Cache](Cache.md) for information on creating and using custom cache classes.