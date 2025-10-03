require_relative "../config/boot"

module Initializer
  class << self
    def configure
      setup_env
      setup_config
      setup_i18n
      setup_database
      setup_sidekiq
    end

    def get_webhook
      @config.dig("bot", "webhook")
    end

    def get_token
      bot_token = @config.dig("bot", "token")
      raise "Telegram token is not configured" if bot_token.nil? || bot_token.empty?
      bot_token
    end

    def get_channel_name
      @config.dig("bot", "channel")
    end

    def get_su_id
      @config.dig("bot", "su_id")
    end

    def get_logger
      @logger ||= Logger.new(
        STDOUT, level: :debug, formatter: proc { |severity, time, progname, msg| "#{time} [#{severity}]: #{msg}\n" }
      )
    end

    private

    def setup_env
      Dotenv.load
      raise "Failed to load .env file or BOT_TOKEN is missing" if ENV['BOT_TOKEN'].nil?
    end

    def setup_config
      @config ||= YAML.load(ERB.new(File.read("config/secrets.yml")).result)
    end

    def setup_i18n
      I18n.load_path += Dir[File.join(File.expand_path("config/locales"), '**', '*.yml')]
      I18n.available_locales = :ru
      I18n.default_locale = :ru
      I18n.backend.load_translations
    end

    def setup_database
      db_config = YAML.load(ERB.new(File.read("config/database.yml")).result, aliases: true)
      ActiveRecord::Base.logger = get_logger
      ActiveRecord::Base.establish_connection(db_config[ENV.fetch("RACK_ENV", "development")])
    end

    def setup_sidekiq
      redis_url = @config.dig("bot", "redis_url")
      Sidekiq.configure_server do |config|
        config.redis = { url: redis_url }
        config.logger = get_logger
        # Loading task from schedule.yml
        schedule_file = File.expand_path("config/schedule.yml", __FILE__)
        if File.exist?(schedule_file)
          Sidekiq::Cron::Job.load_from_hash(YAML.load_file(schedule_file))
        else
          get_logger.warn "Sidekiq-Cron: file #{schedule_file} not found"
        end
      end
      Sidekiq.configure_client { |config| config.redis = { url: redis_url } }
    end
  end
end