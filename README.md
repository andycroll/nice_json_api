# NiceJsonApi

A useful hundred-line-ish wrapper around `Net::HTTP` for well behaved JSON-based APIs.

This gem can be used as a basis for http://jsonapi.org compatible APIs but it is not exclusively for that use. Any 'nice' JSON-based API should work.

If you're looking for a good gem to use with JSON API I like [json-api-vanilla](https://github.com/trainline/json-api-vanilla).

Supports Authorization:
* HTTP Basic Auth
* Bearer Token Auth (like Twitter)
* Other header-based authorisation (custom header & value)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nice_json_api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nice_json_api

## Usage

The main interface is:

```ruby
# A simple GET request
> response = NiceJsonApi::Response.new('http://ip.jsontest.com')
=> #<NiceJsonApi::Response:...>
> response.code
#=> '200'
> response.body
#=> { ip: '8.8.8.8' }
> response.raw_body
#=> "{\"ip\": \"146.199.147.93\"}\n"
> response.message
#=> "OK"
> response.raw
#=> #<Net::HTTPOK 200 OK readbody=true>

# A Bearer token POST request
> response = NiceJsonApi::Response.new('https://api.twitter.com/1.1/statuses/update.json',
                                       auth: { bearer: "YOURTOKEN" },
                                       body: { status: 'This gem is awesome' },
                                       method: :post)

# A custom header GET request
> response = NiceJsonApi::Response.new('https://yourapiserver.com/',
                                       auth: { header: { name: 'X-Weird-Auth', value: 'TOKEN' } })
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/nice_json_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the NiceJsonApi project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/nice_json_api/blob/master/CODE_OF_CONDUCT.md).
