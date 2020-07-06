ENV['RAILS_ENV'] = 'test'
ENV['DB'] ||= 'sqlite3'

require 'rails/all'
require 'rails/test_help'
require 'pagy_keyset'
require 'dummy/config/environment'

ActiveRecord::Migration.verbose = false
ActiveRecord::Tasks::DatabaseTasks.drop_current 'test'
ActiveRecord::Tasks::DatabaseTasks.create_current 'test'
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

class TestController
  include Pagy::Backend

  def params
    @params ||= {}
  end
end
