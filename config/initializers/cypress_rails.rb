return unless Rails.env.test?

Rails.application.load_tasks unless defined?(Rake::Task)

CypressRails.hooks.before_server_start do
  # Add our fixtures before the resettable transaction is started
  Rake::Task["db:fixtures:load"].invoke
end

CypressRails.hooks.after_transaction_start do
  # add test objects
end

CypressRails.hooks.after_state_reset do
  # check test objects
end

CypressRails.hooks.before_server_stop do
  # Purge and reload the test database so we don't leave our fixtures in there
  Rake::Task["db:test:prepare"].invoke
end
