# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem 'rubyist-aasm', :version => '~> 2.0.2', :lib => 'aasm', :source => "http://gems.github.com"
  config.gem 'rvideo', :version => '>= 0.9.3'
  config.gem 'right_aws', :version => '>= 1.9.0'
  config.gem 'ap4r'

  config.time_zone = 'UTC'

  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_video2_session',
    :secret      => '12f5f69964c09212b3e43e96e34f37903e3b10db6bf5e5066871249783d977ed60c8b8ec00a3aa271317500e2db1a1ef47a4e8e1b09f932da53a5a6a0b387a0a'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types

  # Activate observers that should always be running
  # Please note that observers generated using script/generate observer need to have an _observer suffix
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
end
