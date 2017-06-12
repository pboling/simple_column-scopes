require 'simple_column/scopes'
require 'simple_column/scopes/version'

# Purpose:
# Create dynamic modules which define dynamic methods for scopes based on a dynamic array of column names
#
# Library Usage:
#
# class Monkey < ActiveRecord::Base
#
#   include SimpleColumn::Scopes.new(:for_user_id, :for_seller_id, ... etc)
#   # => for_user_id, and for_seller_id scopes are added to the model,
#         and they query on the user_id and seller_id columns, respectively
#
module SimpleColumn
  SCOPE_PREFIX = 'for_'.freeze
  SCOPE_PREFIX_REGEX = Regexp.new("\\A#{SimpleColumn::SCOPE_PREFIX}")
  class << self
    # returns an anonymous (nameless) Module instance
    def to_mod(scope_names_hash)
      Module.new do
        scope_names_hash.each do |scope_name, column_name|
          # methods are defined at the instance level, so will become class methods when this module extends a class.
          define_method(scope_name) do |value|
            where(column_name => value)
          end
        end
      end
    end
  end

  # This is a Class / Module Hybrid (see simple_column/scopes/version.rb)
  Scopes.class_eval do
    def initialize(*scope_names)
      # => { :for_user_id => "user_id" }
      @simple_scope_names_hash = scope_names.map(&:to_sym).each_with_object({}) do |scope_name, memo|
        # method name definitions are best with symbols, and gsub only works on strings.
        memo[scope_name] = scope_name.to_s.sub(SimpleColumn::SCOPE_PREFIX_REGEX, '')
      end
      # Raising an error here is safe, because it will fail on boot if there is an implementation problem (early!)
      unless (bad_scopes = @simple_scope_names_hash.select { |scope_name, column_name| scope_name.to_s == column_name }).blank?
        bad_scope_names(bad_scopes)
      end
    end

    def included(base)
      # How to do this without breaking the build?
      # if ActiveRecord::Base.connection.active?
      #   # Invoking this requires that a database be present.
      #   unless (bad_scopes = @simple_scope_names_hash.reject { |_, column_name| base.column_names.include?(column_name) }).blank?
      #     bad_scope_names(bad_scopes)
      #   end
      # end
      anonymous_module = SimpleColumn.to_mod(@simple_scope_names_hash)
      # This will override methods defined in the including class with the same name, if any,
      #   because extend has the effect of injecting the code into the bottom of the class file, lexically,
      #   making these definitions highest priority.
      base.send(:extend, anonymous_module)
    end

    def bad_scope_names(bad_scopes)
      raise ArgumentError, "SimpleColumn::Scopes need to be named like #{SimpleColumn::SCOPE_PREFIX}<column_name>, but provided #{bad_scopes.keys}"
    end
  end
end
