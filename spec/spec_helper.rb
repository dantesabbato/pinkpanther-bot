require 'rspec'
require 'factory_bot'
require 'database_cleaner'
require_relative '../initializer'

RSpec.configure do |config|
  config.expect_with(:rspec) { |expectations| expectations.include_chain_clauses_in_custom_matcher_descriptions = true }
  config.mock_with(:rspec) { |mocks| mocks.verify_partial_doubles = true }
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.before(:suite) { DatabaseCleaner.strategy = :transaction; DatabaseCleaner.clean_with(:truncation) }
  config.before(:each) { DatabaseCleaner.start }
  config.after(:each) { DatabaseCleaner.clean }
  config.include FactoryBot::Syntax::Methods
end
