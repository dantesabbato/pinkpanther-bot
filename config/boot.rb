# Core Ruby libraries
require "logger"
require "erb"
require "yaml"
require "debug"
require "net/http"
require "uri"
require "json"
# Gems
require "dotenv"
require "i18n"
require "active_record"
require "active_support"
require "active_support/core_ext/object"
require "sidekiq"
require "sidekiq-cron"
require "sidekiq/throttled"
require "telegram/bot"
# Add `lib` to load path
$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
# Application modules
require_relative "initializer"
require_relative "../lib/services/telegram_service"
require_relative "../lib/services/inflector_service"
require_relative "../lib/services/matchmaker_service"
# Auto-load models, processors, and workers
Dir[
  "#{__dir__}/../lib/models/**/*.rb",
  "#{__dir__}/../lib/processors/_concerns/*.rb",
  "#{__dir__}/../lib/processors/**/*.rb",
  "#{__dir__}/../lib/workers/**/*.rb"
].sort.each { |file| require file }