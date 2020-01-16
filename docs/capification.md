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
    gem 'capistrano-bundler'
    gem 'capistrano-ext'
    gem 'capistrano-passenger'
    gem 'capistrano-rails'
    gem 'capistrano-sidekiq'
    ```
  Add these to your top level Gemfile section if they aren't there yet:
    ```ruby
    gem 'pg'
    gem 'sidekiq'
    gem 'dotenv-rails'
    ```
  Run `bundle install`

  *Note*: If `pg` and `sidekiq` haven't been added to the project yet, chances are good they aren't really setup properly. Don't forget to go back and check that.

  *Note*: If you haven't worked with `dotenv-rails` before, you might want to read the [DCE playbook entries](https://curationexperts.github.io/playbook/practices/environment_variables.html) about it. You will need a file on your server called `.env.production` where you will define the environment variables referenced in your config files above, such as `SOLR_URL`, `FEDORA_URL`, and `FEDORA_PASSWORD`.

1. Make some DCE specific stages, instead of just the defaults: `bundle exec cap install STAGES=localhost,sandbox,qa,staging,production`
1. Edit the newly created `config/deploy/localhost.rb` so it contains:
  ```ruby
   server '127.0.0.1', user: 'deploy', roles: [:web, :app, :db]
  ```
1. Edit the newly created `config/deploy.rb` file:
  * Add the `:application` name
  * Add the github `:repo_url` using the https version (e.g., https://github.com/curationexperts/whatever.git)
  * Add this boilerplate, customizing as appropriate:

  ```ruby
    set :deploy_to, '/opt/YOUR_PROJECT_NAME'

    set :log_level, :info
    set :bundle_flags, '--deployment'
    set :bundle_env_variables, nokogiri_use_system_libraries: 1
    set :rails_env, 'production'

    set :keep_releases, 5
    set :assets_prefix, "#{shared_path}/public/assets"

    SSHKit.config.command_map[:rake] = 'bundle exec rake'

    set :branch, ENV['REVISION'] || ENV['BRANCH_NAME'] || ENV['BRANCH'] || 'master'

    append :linked_dirs, "log"
    append :linked_dirs, "public/assets"

    append :linked_files, "config/secrets.yml"
    append :linked_files, "config/database.yml"
    append :linked_files, ".env.production"


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
