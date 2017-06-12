# SimpleColumn::Scopes

Create dynamic modules which define dynamic methods for scopes based on a dynamic array of column names!

## Why?

Why replace a simple `where` query with a method from a DSL like this?
  
* Tokenizing your logic makes it easy to find with grep or other search tools.
  - Do a search for `.where(` in a large codebase, and may wish the specific thing you are looking for was tokenized.
* Creating small blocks of logic on which to build, of a uniform nature, can make applications
  - more robust (this will raise a noisy error on a typo - if the column doesn't exist, or the scope prefix is incorrect)
  - reduce typos (see above)
  - reduce mental overhead (the same pattern every time, no variation; `for_<column_name>` always means the same thing)
* Profit

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple_column-scopes'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_column-scopes

## Usage

Given an ActiveRecord model with a column: `user_id`
Create a scope that queries it, by prefixing `for_` to the column name:

```ruby
include SimpleColumn::Scopes.new(:for_user_id)
```
is equivalent to:
```ruby
def self.for_user_id(user_id)
  where(user_id: user_id)
end
```

Complete example\*:

```ruby
# == Schema Information
#
# Table name: monkeys
#
#  id             :integer(4)       not null, primary key
#  user_id        :integer(4)
#  seller_id  :integer(4)
class Monkey < ActiveRecord::Base

  include SimpleColumn::Scopes.new(:for_user_id, :for_seller_id, :etc)
  # => for_user_id, and for_seller_id scopes are added to the model,
  #       and they query on the user_id and seller_id columns, respectively
end

Monkey.for_user_id(1)
Monkey.for_seller_id(2)
```

\* This software may not be suitable for buying and selling of Monkeys.  This is simply a contrived example.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tophatter/simple_column-scopes. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SimpleColumn::Scopes project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/tophatter/simple_column-scopes/blob/master/CODE_OF_CONDUCT.md).
