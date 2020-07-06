# frozen_string_literal: true

require 'pagy_keyset/builder_iterator'

module PagyKeyset
  module CursorBuilder
    class << self
      def call(collection, items, builders: nil)
        PagyKeyset::BuilderIterator
          .call(collection, builders: builders) do |builder|
            builder.build_cursors(collection, items)
          end
      end
    end
  end
end
