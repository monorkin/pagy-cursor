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

    def initialize(args)
      @vars = VARS.merge(args.delete_if { |_, v| v.nil? || v == '' })
      @items = vars[:items] || VARS[:items]
      @before = vars[:before]
      @after = vars[:after]
      @current = @after || @before

      if before? && after?
        raise(PagyKeyset::UnknownDirectionError,
              'both before and after cursors given')
      end

      @cursor = PagyKeyset::Coder.decode_cursor(
        @before || @after,
        secret: vars[:secret]
      )
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
      cursors = PagyKeyset::CursorBuilder.call(collection, items)

      @next_cursor = cursors[:next]
      @next = PagyKeyset::Coder.encode_cursor(@next_cursor) if @next_cursor
      @prev_cursor = cursors[:prev]
      @prev = PagyKeyset::Coder.encode_cursor(@prev_cursor) if @prev_cursor
    end

    def more?
      return false if next_cursor.nil?
      return false if next_cursor.empty?

      cursor != next_cursor &&
        cursor != prev_cursor
    end
  end
end
