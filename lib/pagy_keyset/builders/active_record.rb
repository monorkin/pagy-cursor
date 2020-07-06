# frozen_string_literal: true

require 'pagy_keyset/error'

module PagyKeyset
  module Builders
    module ActiveRecord
      class << self
        UNSCOPE_VALUES =
          ::ActiveRecord::QueryMethods::VALID_UNSCOPING_VALUES.clone

        def accepts?(collection)
          return false unless defined?(::ActiveRecord::Relation)

          collection.is_a?(::ActiveRecord::Relation)
        end

        def build_query(cursor, collection, items, direction)
          if direction == :after
            return build_after_query(cursor, collection, items)
          end

          build_before_query(cursor, collection, items)
        end

        def build_cursors(collection, items)
          columns = build_order_clause(collection).map { |t| t[:column] }

          if columns.empty?
            raise(EmptyCursorError, 'at least one order argument is required '\
                                    'in the query to create a cursor')
          end

          {
            prev: column_values(columns, collection.limit(1)),
            next: column_values(columns, collection.limit(1)
                  .offset([0, items - 1].max))
          }
        end

        private

        def build_after_query(cursor, collection, items)
          order_clause = build_order_clause(collection)
          build_comparison_clause(collection, order_clause, cursor).limit(items)
        end

        def build_before_query(cursor, collection, items)
          subquery = collection.reverse_order
          order_clause = build_order_clause(subquery)

          build_comparison_clause(
            subquery,
            order_clause,
            cursor
          ).limit(items)
        end

        def build_order_clause(collection)
          collection.order_values.flat_map do |value|
            case value
            when String
              build_order_clause_from_string(value)
            when Arel::Nodes::Ordering
              build_order_clause_from_arel(value)
            end
          end
        end

        def build_order_clause_from_string(value)
          value.split(',').map do |term|
            column, direction = term.strip.split(/\s+/)
            first_direction_letter = direction.to_s.downcase[0]
            direction = first_direction_letter == 'd' ? :desc : :asc

            {
              column: column,
              direction: direction
            }
          end
        end

        def build_order_clause_from_arel(arel)
          {
            column: [
              arel.value.relation.table_alias || arel.value.relation.name,
              arel.value.name
            ].join('.'),
            direction: arel.direction
          }
        end

        def build_comparison_clause(collection, order_clause, cursor)
          comparitor = order_clause.first.fetch(:direction) == :asc ? '>' : '<'

          order_clause.reduce(collection) do |query, term|
            column_name = term[:column]
            next query unless cursor.key?(column_name)

            value = cursor[column_name]

            query.where("#{column_name} #{comparitor} ?", value)
          end
        end

        def column_values(columns, query)
          query = query.select(*columns)
          values =
            ::ActiveRecord::Base.connection.execute(query.to_sql).to_a.first
          values = values.values if values.is_a?(Hash)

          return if values.nil?

          columns.zip(values).to_h
        end
      end
    end
  end
end
