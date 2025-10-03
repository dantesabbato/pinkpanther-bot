module MessageProcessor::Group
  class Ping
    include Processor
    include ProcessorGroup

    def responds?
      super && just_anchor?
    end

    def process!
      [{ send_message: { chat_id:, reply_to_message_id: message_id, text: (I18n.t "bot.ping").sample } }]
    end
  end
end