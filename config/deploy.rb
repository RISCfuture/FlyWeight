require File.expand_path('./environment', __dir__)

# config valid for current version and patch releases of Capistrano
lock '~> 3.16.0'

set :application, 'flyweight'
set :user, 'deploy'
set :repo_url, 'https://github.com/RISCfuture/FlyWeight.git'

# Default branch is :master
set :branch, 'main'

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/flyweight.org"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, 'config/master.key'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets',
       'node_modules', 'public/packs'

# Default value for default_env is {}
set :default_env, {path: '/usr/local/nvm/versions/node/v15.12.0/bin:$PATH'}

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

set :rvm_ruby_version, "3.0.1@#{fetch :application}"
set :sidekiq_config, 'config/sidekiq.yml'
set :bugsnag_api_key, Rails.application.credentials.bugsnag_api_key
set :passenger_restart_with_sudo, true

namespace :sidekiq do
  task :restart do
    on roles(:app) do
      sudo 'systemctl', 'restart', 'sidekiq-flyweight'
    end
  end
end

after 'deploy:finished', 'sidekiq:restart'
after 'deploy:updated', 'webpacker:precompile'
