# frozen_string_literal: true

module PagyKeyset
  class Error < StandardError; end

  class CursorError < Error; end
  class InvalidCursorError < CursorError; end
  class UnknownDirectionError < CursorError; end
  class EmptyCursorError < CursorError; end

  class WhereClauseBuilderError < Error; end
  class NoBuilderForCollectionError < WhereClauseBuilderError; end
end
