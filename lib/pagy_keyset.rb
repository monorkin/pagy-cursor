require 'pagy'

module PagyKeyset
end

Pagy::VARS[:keyset_secret] ||= nil
Pagy::VARS[:before_page_param] ||= :before
Pagy::VARS[:after_page_param] ||= :after

require 'pagy_keyset/version'
