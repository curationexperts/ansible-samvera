### Capify a Rails app the ansible-samvera way

1. Check out the project and ensure the tests pass
1. Edit `config/solr.yml` to add the production solr url:
  ```ruby
    production:
    url: <%= ENV['SOLR_URL'] %>
  ```
1. Edit `config/blacklight.yml` to add the production solr url:
```ruby
  production:
    adapter: solr
    url: <%= ENV['SOLR_URL'] %>
```
1. Edit `config/fedora.yml` to add the production fedora settings:
```
  production:
    user: fedoraAdmin
    password: <%= ENV['FEDORA_PASSWORD'] %>
    url: <%= ENV['FEDORA_URL'] %>
    base_path: /prod
```
1. Add these gems to your `Gemfile`, in the `:development` section:
  ```ruby
  gem 'capistrano'
  gem 'capistrano-bundler', '~> 1.3'
  gem 'capistrano-ext'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-sidekiq', '~> 0.20.0'
  ```
  Add these to your top level Gemfile section if they aren't there yet:
  ```ruby
  gem 'pg', '~> 0.18'
  gem 'sidekiq'
  ```
  Run `bundle install`

  *Note*: If `pg` and `sidekiq` haven't been added to the project yet, chances are good they aren't really setup properly. Don't forget to go back and check that.
  *Note*: Pinning `pg` to a pre-1.0 version is necessary because of this bug: https://github.com/rails/rails/issues/31678. Hopefully this will not always be the case.
1. Make some DCE specific stages, instead of just the defaults: `bundle exec cap install STAGES=localhost,sandbox,qa,staging,production`
1. Edit the newly created `config/deploy/localhost.rb` so it contains:
  ```ruby
   set :stage, :localhost
   set :rails_env, 'production'
   server '127.0.0.1', user: 'deploy', roles: [:web, :app, :db]
  ```
1. Edit the newly created `config/deploy.rb` file:
  * Add the `:application` name
  * Add the github `:repo_url`
  * Add this boilerplate, customizing as appropriate:

  ```ruby
    set :deploy_to, '/opt/YOUR_PROJECT_NAME'

    set :log_level, :debug
    set :bundle_flags, '--deployment'
    set :bundle_env_variables, nokogiri_use_system_libraries: 1

    set :keep_releases, 5
    set :assets_prefix, "#{shared_path}/public/assets"

    SSHKit.config.command_map[:rake] = 'bundle exec rake'

    set :branch, ENV['REVISION'] || ENV['BRANCH_NAME'] || 'master'

    append :linked_dirs, "log"
    append :linked_dirs, "public/assets"

    append :linked_files, "config/database.yml"
    append :linked_files, "config/secrets.yml"

    # We have to re-define capistrano-sidekiq's tasks to work with
    # systemctl in production. Note that you must clear the previously-defined
    # tasks before re-defining them.
    Rake::Task["sidekiq:stop"].clear_actions
    Rake::Task["sidekiq:start"].clear_actions
    Rake::Task["sidekiq:restart"].clear_actions
    namespace :sidekiq do
      task :stop do
        on roles(:app) do
          execute :sudo, :systemctl, :stop, :sidekiq
        end
      end
      task :start do
        on roles(:app) do
          execute :sudo, :systemctl, :start, :sidekiq
        end
      end
      task :restart do
        on roles(:app) do
          execute :sudo, :systemctl, :restart, :sidekiq
        end
      end
    end
  ```

  Note: You do NOT want the `:passenger_restart_with_touch` option. This will prevent passenger from automatically restarting after you deploy. See https://github.com/capistrano/passenger#restarting-passenger--4033-applications
1. Add this content to your `Capfile`:
  ```ruby
      # Load DSL and set up stages
    require "capistrano/setup"

    # Include default deployment tasks
    require "capistrano/deploy"

    # Use bundler to install gem requirements
    require 'capistrano/bundler'
    require 'capistrano/rails'
    require 'capistrano/sidekiq'
    require 'capistrano/passenger'
    require "capistrano/scm/git"
    install_plugin Capistrano::SCM::Git

    # Load custom tasks from `lib/capistrano/tasks` if you have any defined
    Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
  ```
