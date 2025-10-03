require "redis"

module MessageProcessor::Group
  class Triggers
    include ProcessorGroup

    CHAR_REPLACEMENTS = {
      'а' => /[aA]/, 'е' => /[eE]/, 'о' => /[oO]/, 'с' => /[cC]/, 'р' => /[pP]/, 'у' => /[yY]/,
      'х' => /[xX]/, 'в' => /[B]/, 'м' => /[M]/, 'н' => /[H]/, 'к' => /[K]/, 'т' => /[T]/
    }.freeze

    def responds?
      return false unless super
      return false if @member.is_superior || @member.message_count.to_i > 5
      contains_arabic? ||
        contains_words? ||
        contains_tlink? ||
        contains_link? ||
        contains_photo? ||
        contains_video? ||
        contains_repeated_mentions? ||
        contains_multiple_photos?
    end

    def process!
      actions = []
      actions << delete_message(message_id) if !@message["media_group_id"] && can_delete_messages?
      actions.concat notify_and_restrict if should_notify_and_restrict?
      actions
    end

    private

    def trigger
      @chat.trigger
    end

    def redis
      @redis ||= Redis.new(url: ENV['REDIS_URL'])
    end

    def should_notify_and_restrict?
      if @message["media_group_id"]
        key = "trigger:media_group:#{@message["media_group_id"]}"
        if redis.setnx(key, "true")
          redis.expire(key, 60)
          true
        else
          false
        end
      else
        true
      end
    rescue Redis::BaseError => e
      Initializer.get_logger.error "Redis error in should_notify_and_restrict?: #{e.message}"
      false
    end

    def notify_and_restrict
      actions = []
      actions << restrict_member if can_restrict_members?
      group_admins.each do |admin|
        next unless (private = Private.find_by(id: admin.user.id))
        next unless (message = send_notification(private.id))
        media = send_media(private.id)
        create_notification(private.id, message.message_id, "trigger") if message.message_id
        create_notification(private.id, media.message_id, "trigger_media") if media&.message_id
      end
      if can_delete_messages? && @message["media_group_id"]
        message_key = "trigger:media_group_messages:#{@message["media_group_id"]}"
        message_ids = redis.lrange(message_key, 0, -1)
        message_ids.each { |message_id| actions << delete_message(message_id) }
        redis.del(message_key)
      end
      actions
    rescue Redis::BaseError => e
      Initializer.get_logger.error "Redis error in notify_and_restrict: #{e.message}"
      actions
    end

    def contains_repeated_mentions?
      return false unless trigger&.repeated_mentions_trigger
      return false if message_text.nil?
      mentions = message_text.scan(/@\w+/)
      return false if mentions.empty?
      mentions.group_by(&:itself).any? { |_nick, arr| arr.size >= 3 }
    end

    def contains_arabic?
      trigger&.arabic_words_trigger && message_text&.match?(/\p{Arabic}/)
    end

    def contains_words?
      return unless trigger&.banned_words_trigger
      normalized_text = normalize_text(message_text)
      banned_phrases = TriggerWord.where(group_id: group.id).pluck(:word).map { |phrase| normalize_text(phrase) }
      banned_phrases.any? { |phrase| normalized_text.include?(phrase) }
    end

    def contains_tlink?
      trigger&.telegram_links_trigger && message_text&.match?(/(t\.me|telegram\.me)\/\w+/)
    end

    def contains_link?
      trigger&.links_trigger && message_text&.match?(%r{https?://\S+})
    end

    def contains_photo?
      trigger&.pics_trigger && (@message.respond_to?("photo") || @message["photo"]&.any?)
    end

    def contains_multiple_photos?
      return false unless trigger&.multiple_pics_trigger
      return false unless @message["photo"]&.any?
      if @message["media_group_id"]
        message_key = "trigger:media_group_messages:#{@message["media_group_id"]}"
        redis.lpush(message_key, @message["message_id"])
        redis.expire(message_key, 60)
        media_count = redis.llen(message_key)
        media_count > 2
      else
        false
      end
    rescue Redis::BaseError => e
      Initializer.get_logger.error "Redis error in contains_multiple_photos?: #{e.message}"
      false
    end

    def contains_video?
      trigger&.videos_trigger && (@message.respond_to?("video") || @message["video"]&.any?)
    end

    def normalize_text(str)
      return "" if str.nil?
      normalized = str.dup
      CHAR_REPLACEMENTS.each { |cyr, lat| normalized.gsub!(lat, cyr) }
      normalized.gsub(/[^\p{L}\p{N}\s]/, '').gsub(/\s+/, ' ').strip
    end

    def group_admins
      @bot.getChatAdministrators(chat_id: @message["chat"]["id"].to_i).reject { |admin| admin.user.is_bot }
    end

    def delete_message(message_id)
      { delete_message: { chat_id: group.telegram_id, message_id: message_id.to_i } }
    end

    def restrict_member
      { restrict_chat_member: { chat_id: group.telegram_id, user_id: user.id, until_date: (Time.now.to_i + 86400) } }
    end

    def send_notification(id)
      @bot.send_message(
        chat_id: id,
        text: I18n.t(
          "triggers.notification.text",
          group: @chat.title,
          user: @user.link,
          user_message: message_text&.slice(0, 100)
        ),
        reply_markup: Telegram::Bot::Types::InlineKeyboardMarkup.new(
          inline_keyboard: [[
            Telegram::Bot::Types::InlineKeyboardButton.new(
              text: I18n.t("triggers.notification.buttons.ban"), callback_data: "member_action:#{@member.id}:ban"
            ),
            Telegram::Bot::Types::InlineKeyboardButton.new(
              text: I18n.t("triggers.notification.buttons.unmute"), callback_data: "member_action:#{@member.id}:unmute"
            )
          ]]
        ),
        parse_mode: "HTML"
      )
    rescue Telegram::Bot::Exceptions::ResponseError => e
      Initializer.get_logger.error "Error sending notification: #{e.message}"
      nil
    end

    def send_media(id)
      if @message["photo"]&.any?
        @bot.send_photo(chat_id: id, photo: @message["photo"].first["file_id"])
        # [{ send_photo: { chat_id: user_id, photo: @message["photo"].first["file_id"], caption: @message["caption"] } }]
      elsif @message["video"]&.any?
        @bot.send_video(chat_id: id, video: @message["video"].first["file_id"])
        # [{ send_video: { chat_id: user_id, video: @message["video"]["file_id"], caption: @message["caption"] } }]
      end
    end

    def create_notification(user_id, message_id, type)
      member_id = Member.find_by(group: @chat, user_id:).id
      Notification.create!(member_id:, message_id:, type:, value: @member.id)
    rescue ActiveRecord::RecordInvalid => e
      Initializer.get_logger.error "Error creating notification: #{e.message}"
    end
  end
end
