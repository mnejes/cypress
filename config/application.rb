require File.expand_path('boot', __dir__)

require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'
require_relative '../lib/hash'

CAT1_CONFIG = YAML.safe_load(File.read(File.expand_path('cat1checklist.yml', __dir__)), [], [], true)
APP_CONSTANTS = YAML.safe_load(ERB.new(File.read(File.expand_path('cypress.yml', __dir__))).result, [], [], true)
NAMES_RANDOM = YAML.safe_load(File.read(File.expand_path('names.yml', __dir__)), [], [], true)

# Append an additional measure HQMF ID during testing so product creation
# does not fail.
if Rails.env.test?
  CAT1_CONFIG['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] = [{ 'ValueSet' => '1.5.6.7',
                                                           'Weight' => '0.954242509',
                                                           'IsAttribute' => false }]
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Cypress
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run 'rake -D time' for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    # config.active_record.raise_in_transactional_callbacks = true
    config.autoload_paths += Dir["#{config.root}/lib/"]
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

    # prevent rails from wrapping inputs with errors in a div of class "field_with_errors"
    config.action_view.field_error_proc = proc { |html_tag, _instance| html_tag }
    config.active_job.queue_adapter = :delayed_job

    # This lets us define our own routes for error pages
    config.exceptions_app = routes
  end
end
