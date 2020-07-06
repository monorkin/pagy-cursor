# frozen_string_literal: true

require 'pagy_keyset/builders/active_record'

module PagyKeyset
  module BuilderIterator
    class << self
      DEFAULT_BUILDERS = [
        PagyKeyset::Builders::ActiveRecord
      ].freeze

      def call(collection, builders: nil, &block)
        builders = Array(builders).push(*DEFAULT_BUILDERS)

        builders.each do |builder|
          next unless builder.accepts?(collection)

          return block.call(builder)
        end

        raise(
          NoBuilderForCollectionError,
          "no builder accepts a collection of class '#{collection.class}'"
        )
      end
    end
  end
end
