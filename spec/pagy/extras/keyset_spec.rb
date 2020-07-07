# frozen_string_literal: true

require 'spec_helper'
require 'pagy_keyset/pagy/extras/keyset'

RSpec.describe Pagy::Backend do
  include ActiveSupport::Testing::TimeHelpers

  let(:backend) { TestController.new }

  context 'no records' do
    it 'returns an empty collection' do
      pagy, records = backend.send(:pagy_keyset, User.all.order(id: :desc))
      expect(records).to be_empty
      expect(pagy.more?).to eq(false)
    end
  end

  context 'with records' do
    before do
      User.destroy_all
      (1..100).each do |i|
        User.create!(name: "user#{i}")
      end
    end

    it 'paginates with defaults' do
      pagy, records = backend.send(:pagy_keyset, User.all.order(id: :desc))
      expect(records.map(&:name)).to eq(
        ['user100', 'user99', 'user98', 'user97', 'user96',
         'user95', 'user94', 'user93', 'user92', 'user91',
         'user90', 'user89', 'user88', 'user87', 'user86',
         'user85', 'user84', 'user83', 'user82', 'user81'])
      expect(pagy.more?).to eq(true)
    end

    it 'paginates with before' do
      pagy, _ = backend.send(:pagy_keyset, User.all.order(id: :asc), items: 51)
      pagy, records = backend.send(:pagy_keyset, User.all.order(id: :asc), before: pagy.next)
      expect(records.map(&:name)).to eq(
        ['user50', 'user49', 'user48', 'user47', 'user46',
         'user45', 'user44', 'user43', 'user42', 'user41',
         'user40', 'user39', 'user38', 'user37', 'user36',
         'user35', 'user34', 'user33', 'user32', 'user31'])
      expect(pagy.more?).to eq(true)
    end

    it 'paginates with before nearly starting' do
      pagy, _ = backend.send(:pagy_keyset, User.all.order(id: :asc), items: 5)
      pagy, records = backend.send(:pagy_keyset, User.all.order(id: :asc), before: pagy.next)
      expect(records.first.name).to eq('user4')
      expect(records.last.name).to eq('user1')
      expect(pagy.more?).to eq(false)
    end

    it 'paginates with after' do
      pagy, _ = backend.send(:pagy_keyset, User.all.order(id: :asc), items: 30)
      pagy, records = backend.send(:pagy_keyset, User.all.order(id: :asc), after: pagy.next)
      expect(records.first.name).to eq('user31')
      expect(records.last.name).to eq('user50')
      expect(pagy.more?).to eq(true)
    end

    it 'paginates with before nearly starting' do
      pagy, _ = backend.send(:pagy_keyset, User.all.order(id: :asc), items: 90)
      pagy, records = backend.send(:pagy_keyset, User.all.order(id: :asc), after: pagy.next)
      expect(records.first.name).to eq('user91')
      expect(records.last.name).to eq('user100')
      expect(pagy.more?).to eq(false)
    end
  end

  context 'with ordered records' do
    before do
      User.destroy_all

      indexes = (1...100).to_a
      timestamps = indexes.to_a.reverse.map { |i| (i + 42).minutes.ago }
      timestamps[41] = 1.minute.ago

      indexes.zip(timestamps).each do |i, t|
        travel_to t
        User.create!(name: "user#{i}")
      end

      travel_back
    end

    it 'paginates with defaults' do
      pagy, records = backend.send(
        :pagy_keyset,
        User.all.order(updated_at: :desc)
      )

      expect(records.map(&:name)).to eq(
        ['user42', 'user99', 'user98', 'user97', 'user96',
         'user95', 'user94', 'user93', 'user92', 'user91',
         'user90', 'user89', 'user88', 'user87', 'user86',
         'user85', 'user84', 'user83', 'user82', 'user81'])
      expect(pagy.more?).to eq(true)
    end
  end
end
