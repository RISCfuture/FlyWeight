require_relative 'boot'

require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'action_mailer/railtie'
require 'active_job/railtie'
require 'action_cable/engine'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FlyWeight
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = 'Central Time (US & Canada)'
    # config.eager_load_paths << Rails.root.join('extras')

    config.time_zone                      = 'UTC'
    config.active_record.default_timezone = :utc
    config.active_job.queue_adapter       = :sidekiq

    config.generators do |g|
      g.test_framework :rspec, fixture: true, views: false
      g.integration_tool :rspec
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end

    config.x.urls = config_for(:urls)

    # reduce the proliferation of job queues
    config.action_mailer.default_url_options      = config_for(:urls).slice(:host, :port)
    config.action_mailer.deliver_later_queue_name = nil # defaults to "mailers"
    config.active_record.queues.destroy           = nil # defaults to "destroy"
  end
end
