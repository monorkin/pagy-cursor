# frozen_string_literal: true

require 'pagy_keyset/error'
require 'pagy_keyset/coder'
require 'pagy_keyset/query_builder'
require 'pagy_keyset/cursor_builder'

class Pagy
  class Keyset < Pagy
    attr_reader :before
    attr_reader :after
    attr_reader :current
    attr_reader :cursor
    attr_reader :next_cursor
    attr_reader :next
    attr_reader :prev_cursor
    attr_reader :prev
    attr_reader :secret
    attr_reader :item_count

    def initialize(args)
      @vars = VARS.merge(args.delete_if { |_, v| v.nil? || v == '' })
      @secret = vars[:secret]
      @items = vars[:items] || VARS[:items]
      @before = vars[:before]
      @after = vars[:after]
      @current = @after || @before

      if before? && after?
        raise(PagyKeyset::UnknownDirectionError,
              'both before and after cursors given')
      end

      @cursor = PagyKeyset::Coder.decode_cursor(current, secret: secret)
    end

    def after?
      !after.nil?
    end

    def before?
      !before.nil?
    end

    def direction
      before? ? :before : :after
    end

    def where(collection)
      PagyKeyset::QueryBuilder.call(
        cursor,
        collection,
        items,
        direction,
        builders: vars[:keyset_builders]
      )
    end

    def build_new_cursors(collection)
      @item_count = collection.count
      cursors = PagyKeyset::CursorBuilder.call(collection, items)

      @next_cursor = cursors[:next]
      if @next_cursor
        @next = PagyKeyset::Coder.encode_cursor(@next_cursor, secret: secret)
      end

      @prev_cursor = cursors[:prev]
      if @prev_cursor
        @prev = PagyKeyset::Coder.encode_cursor(@prev_cursor, secret: secret)
      end
    end

    def more?
      return false if next_cursor == prev_cursor
      return false if item_count != items

      return cursor != prev_cursor if before?

      cursor != next_cursor
    end
  end
end
