require_relative "../../config/boot"

module TelegramService
  class << self
    def bot_api
      @bot_api ||= Telegram::Bot::Api.new(Initializer.get_token)
    end

    def start
      bot_api
      loop do
        begin
          Telegram::Bot::Client.run(Initializer.get_token) do |bot|
            bot.listen { |update| UpdateWorker.perform_async(update.to_h.deep_stringify_keys) }
          end
        rescue Telegram::Bot::Exceptions::ResponseError => e
          logger = Initializer.get_logger
          error_code = e.error_code rescue nil
          if error_code == 429
            retry_after = e.parameters&.[]('retry_after') || 10
            logger.warn "Rate limit exceeded. Retrying after #{retry_after} seconds..."
            sleep retry_after
          else
            logger.error "Telegram API error: #{e.message} (code: #{error_code || 'unknown'})"
            logger.error e.backtrace.join("\n")
            sleep 5
          end
        rescue StandardError => e
          Initializer.get_logger.error "Unexpected error: #{e.message}"
          Initializer.get_logger.error e.backtrace.join("\n")
          sleep 10
          retry
        end
      end
    end

    delegate :ban_chat_member,
             :unban_chat_member,
             :restrict_chat_member,
             :send_message,
             :send_document,
             :send_photo,
             :send_video,
             :send_video_note,
             :send_voice,
             :send_sticker,
             :send_animation,
             :send_audio,
             :send_poll,
             :send_dice,
             :leave_chat,
             :edit_message_text,
             :edit_message_reply_markup,
             :delete_message,
             to: :bot_api
  end
end