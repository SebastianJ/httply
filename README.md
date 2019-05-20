# Httply

Httply is a lightweight wrapper around Faraday to support automatic randomization of proxies and user agents, amongst other things.

Randomized proxy switching support is provided by the [proxied](https://github.com/SebastianJ/proxied) gem and randomized user agent is provided by the [agents](https://github.com/SebastianJ/agents) gem.

Randomized/automatic proxy switching is currently only supported in conjunction with the [proxied](https://github.com/SebastianJ/proxied) gem. Manual proxy support is obviously supported irregardless of using [proxied](https://github.com/SebastianJ/proxied) or not.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'httply'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install httply

## Usage

### Instance

Httply can either be used as an instance, e.g:

```ruby
client    =   Httply::Client.new(host: "https://www.google.com")
response  =   client.get("/webhp", parameters: {hl: :en})
```

### Class method

Or directly as a class method:

```ruby
response  =   Httply.get("https://www.google.com/webhp", parameters: {hl: :en})
```

### HTML parsing

HTML parsing requires that Nokogiri has been required elsewhere and is accessible for Httply.

You can also force parsing responses as HTML using Nokogiri:

```ruby
response  =   Httply.get("https://www.google.com/webhp", parameters: {hl: :en}, as: :html)
```

response.body will now return a Nokogiri::HTML::Document

### Proxies

Proxy usage:

Proxies can either be used in a normal fashion:

```ruby
response  =   Httply.get("https://www.google.com/webhp", parameters: {hl: :en}, as: :html, options: {proxy: {host: "127.0.0.1", port: 8080, username: "usRnaMe", password: "paswD"}})
```

Or be randomized on a per request basis with the help of [proxied](https://github.com/SebastianJ/proxied):

```ruby
response  =   Httply.get("https://www.google.com/webhp", parameters: {hl: :en}, as: :html, options: {proxy: {randomize: true, protocol: :http, type: :private, category: :private_proxies_x}})
```

Proxy options for randomization are as follows:

- randomize: if proxies should be randomized using [proxied](https://github.com/SebastianJ/proxied)
- protocol: what protocol to use (http or socks), defaults to :http
- type: what type of proxies should be used (public or private), defaults to nil
- category: a specific category to use to further filter proxies from the database, defaults to nil


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/SebastianJ/httply. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Httply project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/SebastianJ/httply/blob/master/CODE_OF_CONDUCT.md).
