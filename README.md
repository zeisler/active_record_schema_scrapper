# ActiveRecordSchemaScrapper
[![Build Status](https://travis-ci.org/zeisler/dissociated_introspection.svg)](https://travis-ci.org/zeisler/dissociated_introspection)
[![Code Climate](https://codeclimate.com/github/zeisler/active_record_schema_scrapper/badges/gpa.svg)](https://codeclimate.com/github/zeisler/active_record_schema_scrapper)
[![Test Coverage](https://codeclimate.com/github/zeisler/active_record_schema_scrapper/badges/coverage.svg)](https://codeclimate.com/github/zeisler/active_record_schema_scrapper/coverage)

This gem gives a simple API for ActiveRecord model meta data, including attributes and associations.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_record_schema_scrapper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_record_schema_scrapper

## Usage

    ActiveRecordSchemaScrapper::Attributes.new(model: User).to_h 
        #=>[{ name: "id", type: Fixnum },
            { name: "name", type: String },
            { name: "email", type: String, default: "" },
            { name: "credits", type: BigDecimal, precision: 19, scale: 6 },
            { name: "created_at", type: DateTime },
            { name: "updated_at", type: DateTime },
            { name: "password_digest", type: String },
            { name: "remember_token", type: Axiom::Types::Boolean, default: true },
            { name: "admin", type: Axiom::Types::Boolean, default: false }]

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/active_record_schema_scrapper/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
