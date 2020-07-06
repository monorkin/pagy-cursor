# frozen_string_literal: true

require 'pagy_keyset/builder_iterator'

module PagyKeyset
  module QueryBuilder
    class << self
      def call(cursor, collection, items, direction = :after, builders: nil)
        PagyKeyset::BuilderIterator
          .call(collection, builders: builders) do |builder|
            builder.build_query(cursor, collection, items, direction)
          end
      end
    end
  end
end
