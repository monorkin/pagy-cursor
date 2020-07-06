require 'pagy_keyset/pagy/keyset'

class Pagy
  module Backend
    private

    def pagy_keyset(collection, vars = {}, _options = {})
      pagy = Pagy::Keyset.new(pagy_keyset_get_vars(collection, vars))
      items = pagy_keyset_get_items(collection, pagy)

      [pagy, items]
    end

    def pagy_keyset_get_vars(_collection, vars)
      vars[:secret] ||= params[vars[:keyset_secret] || VARS[:keyset_secret]]
      vars[:before] ||= params[vars[:before_page_param] || VARS[:before_page_param]]
      vars[:after] ||= params[vars[:after_page_param] || VARS[:after_page_param]]

      vars
    end

    def pagy_keyset_get_items(collection, pagy)
      records = if pagy.cursor
                  pagy.where(collection)
                else
                  collection.limit(pagy.items)
                end

      pagy.build_new_cursors(records)

      records
    end
  end
end
