require "sidekiq"
require_relative "../../config/initializer"

class UpdateProcessor
  MESSAGE_TYPES = %w[text photo video video_note animation voice sticker audio].to_set
  HANDLERS = {
    "chat_instance"    => :handle_callback,
    "new_chat_members" => :handle_new_members_event,
    "left_chat_member" => :handle_left_member_event
  }.freeze

  class << self
    def call(update)
      key = (update.keys & (MESSAGE_TYPES.to_a + HANDLERS.keys)).first
      handler = MESSAGE_TYPES.include?(key) ? :handle_message : HANDLERS[key]
      send(handler, update) if handler
    rescue => e
      Initializer.get_logger.error "Error in UpdateProcessor: #{e.message}"
      Initializer.get_logger.error e.backtrace.join("\n")
    end

    private

    def handle_message(update)
      group, user = learn_entities(update["chat"], update["from"], text: update["text"])
      check_username_change(group, user) if update["chat"]["type"] == "supergroup" || update["chat"]["type"] == "group"
      if update["reply_to_message"] && user && update["reply_to_message"]["from"]["id"] != user.id
        learn_entities(group, update["reply_to_message"]["from"])
      end
      MessageWorker.set(queue: "messages").perform_async(update.to_h.deep_stringify_keys)
    end

    def handle_callback(update)
      learn_entities(update["message"]["chat"], update["from"])
      CallbackWorker
        .set(queue: "callbacks")
        .perform_async(update.to_h.deep_stringify_keys, { "name" => update["message"]["chat"]["type"] })
    end

    def handle_left_member_event(update)
      learn_entities(update["chat"], update["left_chat_member"])
      EventWorker
        .set(queue: "events")
        .perform_async(update.to_h.deep_stringify_keys, { "name" => update["chat"]["type"] })
    end

    def handle_new_members_event(update)
      group, user = learn_entities(update["chat"], update["from"])
      update["new_chat_members"].each do |new_user|
        new_user = user if new_user["id"] == user.id
        learn_entities(group, new_user)
      end
      EventWorker
        .set(queue: "events")
        .perform_async(update.to_h.deep_stringify_keys, { "name" => update["chat"]["type"] })
    end

    def learn_entities(chat, user, text: nil)
      group = chat.is_a?(Group) ? chat : (Group.learn(chat) if chat["type"] == "supergroup" || chat["type"] == "group")
      user = user.is_a?(User) ? user : User.learn(user)

      case chat["type"]
      when "supergroup", "group"
        begin
          Member.learn(group, user, text: text)
        rescue Telegram::Bot::Exceptions::ResponseError => e
          if e.message.include?("Forbidden: bot was kicked from the supergroup chat")
            group.update!(enabled: false)
            return nil
          end
          raise
        end
      when "private"
        Private.learn(user)
      end

      [group, user]
    end

    def check_username_change(group, user)
      return unless user.persisted? && user.id_previously_was.present?
      return unless user.saved_change_to_first_name? || user.saved_change_to_last_name?

      old_first_name = user.saved_change_to_first_name&.first || user.first_name
      old_last_name = user.saved_change_to_last_name&.first || user.last_name
      old_name = [old_first_name, old_last_name].compact.join(" ")

      params = {
        chat_id: group.telegram_id,
        text: I18n.t("members.changed_name", old_name: old_name, new_name: user.link),
        parse_mode: "HTML"
      }
      PayloadWorker.perform_async("send_message", params.to_h.deep_stringify_keys)
    end
  end
end