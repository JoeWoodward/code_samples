# config/initializers/chargify.rb

# uses chargify api gem
require 'chargify_api_ares'

begin

  # get the API keys from config/chargify.yml
  Chargify.configure do |c|
    c.subdomain = ENV['CHARGIFY_SUBDOMAIN']
    c.api_key = ENV['CHARGIFY_API_KEY']
  end

rescue
  nil
end
