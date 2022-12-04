# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.3"

# FRAMEWORK
gem "bootsnap", require: false
gem "net-imap", require: false
gem "net-pop", require: false
gem "net-smtp", require: false
gem "psych", "<4"
gem "rack-cors"
gem "rails"

# AUTH
gem "devise"

# MODELS
gem "kaminari"
gem "validates_timeliness", "6.0.0.beta2"

# CONTROLLERS
gem "responders"

# VIEWS
gem "slim-rails"
gem "turbo-rails"
gem "webpacker"

# ERRORS
gem "bugsnag"

# SERVICES
gem "pg"
gem "puma"
gem "redis"
gem "sidekiq"

group :development do
  # BOOT
  gem "listen"
  gem "spring"

  # ERRORS
  gem "better_errors"
  gem "binding_of_caller"

  # DEPLOY
  gem "bcrypt_pbkdf", require: false
  gem "capistrano-bundler", require: false
  gem "capistrano-rails", require: false
  gem "capistrano-rvm", require: false
  gem "capistrano-sidekiq", require: false
  gem "capistrano-webpacker-precompile", require: false
  gem "ed25519", require: false
end

group :test do
  # TESTING
  gem "rails-controller-testing"
  gem "rspec-rails"

  # FACTORIES
  gem "factory_bot_rails"
  gem "ffaker"

  # ISOLATION
  gem "database_cleaner"
  gem "timecop"
  gem "webmock"
end

group :development, :test do
  gem "cypress-rails"
end

group :doc do
  gem "redcarpet", require: nil
  gem "yard", require: nil
end
