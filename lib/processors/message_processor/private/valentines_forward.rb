module MessageProcessor::Private
  class ValentinesForward
    include Processor

    def responds?
      Valentine.exists?(sender_id: user.id, status: "pending")
    end

    def process!
      Initializer.get_logger.debug "Processing ValentineForward....."
      valentine = Valentine.find_by(sender_id: user.id, status: "pending")
      Initializer.get_logger.debug "VALENTINE: #{valentine.inspect}"
      return unless valentine
      valentine.update!(
        text:       message_text,
        photo:      @message["photo"]&.last&.dig("file_id"),
        video:      @message["video"]&.dig("file_id"),
        voice:      @message["voice"]&.dig("file_id"),
        animation:  @message["animation"]&.dig("file_id"),
        sticker:    @message["sticker"]&.dig("file_id"),
        video_note: @message["video_note"]&.dig("file_id"),
        audio:      @message["audio"]&.dig("file_id"),
        caption:    @message["caption"],
        status:     "sent"
      )
      [{
        send_message: {
          chat_id: user.id,
          text: I18n.t("valentines.send.text_done"),
          reply_markup: {
            inline_keyboard: [[{
              text: I18n.t("valentines.send.buttons.resend"),
              callback_data: "valentines_answer:#{valentine.recipient.id}"
            }]]
          }
        }
      }] + recipient_messages(valentine)
    end

    private

    def recipient_messages(valentine)
      chat_id = valentine.recipient.id
      media = valentine.slice("photo", "video", "voice", "animation", "sticker").compact
      Initializer.get_logger.debug "MEDIA: #{media.inspect}"
      messages = [{
        send_message: {
          chat_id: chat_id,
          text: I18n.t("valentines.send.text_receive", content: valentine.text),
          reply_markup: {
            inline_keyboard: [[
              { text: I18n.t("valentines.send.buttons.reply"), callback_data: "valentines_answer:#{user.id}" }
            ]]
          }
        }
      }]
      return messages if media.empty?
      key, file_id = media.first
      method = case key
               when "photo"        then :send_photo
               when "video"        then :send_video
               when "voice"        then :send_voice
               when "animation"    then :send_animation
               when "sticker"      then :send_sticker
               when "video_note"   then :send_video_note
               else "send_message"
               end
      message_data = { method => { chat_id: chat_id, key.to_sym => file_id } }
      message_data[method][:caption] = valentine.caption  if %w[photo video].include?(key) && valentine.caption.present?
      Initializer.get_logger.debug "MASSAGE DATA: #{message_data.inspect}"
      messages << message_data
    end
  end
end