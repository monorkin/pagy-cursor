# frozen_string_literal: true

require 'json'
require 'base64'
require 'securerandom'
require 'pagy_keyset/error'

module PagyKeyset
  module Coder
    class << self
      NOUNCE_SEPARATOR = '$'

      def encode_cursor(params, secret: nil)
        cursor = params.to_json

        Base64.urlsafe_encode64(encrypt_cursor(cursor, secret))
      end

      def decode_cursor(cursor, secret: nil)
        return if cursor.nil?

        cursor = extract_plain_cursor(Base64.urlsafe_decode64(cursor), secret)

        JSON.parse(cursor)
      rescue JSON::ParserError, ArgumentError => e
        raise(PagyKeyset::InvalidCursorError, source: e)
      end

      private

      def encrypt_cursor(cursor, secret)
        return cursor if secret.nil?

        nounce = SecureRandom.hex(cursor.length)
        encrypted_cursor = xor_encrypt(cursor, secret)

        [
          xor_encrypt(nounce, secret),
          xor_encrypt(encrypted_cursor, nounce)
        ].join(NOUNCE_SEPARATOR)
      end

      def extract_plain_cursor(cursor, secret)
        return cursor if secret.nil?

        encrypted_nounce, nounce_cursor = cursor.split(NOUNCE_SEPARATOR, 2)
        nounce = xor_encrypt(encrypted_nounce, secret)
        encrypted_cursor = xor_encrypt(nounce_cursor, nounce)
        xor_encrypt(encrypted_cursor, secret)
      end

      def xor_encrypt(text, secret)
        length = text.length
        text = text.unpack('U*').each.cycle
        secret = secret.unpack('U*').each.cycle

        text
          .take(length)
          .zip(secret.take(length))
          .map { |l, r| l ^ r }
          .pack('U*')
      end
    end
  end
end
