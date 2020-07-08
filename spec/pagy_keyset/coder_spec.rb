# frozen_string_literal: true

require 'spec_helper'
require 'pagy_keyset/coder'

RSpec.describe PagyKeyset::Coder do
  describe '#encode_cursor' do
    let(:cursor) { { 'posts.id' => 50 } }
    let(:secret) { nil }

    subject { described_class.encode_cursor(cursor, secret: secret) }

    context 'without a secret' do
      let(:secret) { nil }

      it 'returns a URL-safe Base64 encoded JSON encoded object' do
        expect(subject).to be_a(String)

        expect do
          Base64.urlsafe_decode64(subject)
        end.not_to raise_error(Exception)

        json_cursor = Base64.urlsafe_decode64(subject)

        expect do
          JSON.parse(json_cursor)
        end.not_to raise_error(Exception)

        decoded_cursor = JSON.parse(json_cursor)

        expect(decoded_cursor).to eq(cursor)
      end
    end

    context 'with a secret' do
      let(:secret) { 'secret123' }

      it 'returns a URL-safe Base64 encoded XOR encrypted JSON encoded object' do
        expect(subject).to be_a(String)

        expect do
          Base64.urlsafe_decode64(subject)
        end.not_to raise_error(Exception)

        encrypted_nounce_cursor = Base64.urlsafe_decode64(subject)

        expect(encrypted_nounce_cursor.include?('$')).to eq(true)

        encrypted_nounce, encrypted_cursor = encrypted_nounce_cursor.split('$', 2)

        cursor_from_encrypted_nounce =
          PagyKeyset::Coder.send(:xor_encrypt, encrypted_cursor, encrypted_nounce)

        # Using the encrypted nounce shouldn't produce a plaintext cursor
        expect do
          JSON.parse(cursor_from_encrypted_nounce)
        end.to raise_error(Exception)

        # The encrypted nounce shouldn't contain the cursor
        expect do
          JSON.parse(encrypted_nounce)
        end.to raise_error(Exception)

        # The encrypted cursor shouldn't be unencrypted
        expect do
          JSON.parse(encrypted_cursor)
        end.to raise_error(Exception)

        expect(described_class.decode_cursor(subject, secret: secret)).to eq(cursor)
      end
    end
  end
end
