module Processor
  attr_reader :message, :bot

  def initialize(message, bot, user, chat, member)
    @message = message
    @bot = bot
    @user = user
    @chat = chat
    @member = member
  end

  def process
    process! if responds?
  end

  private

  def command
    message_text_down&.split(" ")&.first[1..] if message_text&.chars&.first == "/"
  end

  def command_to_user
    words[1..].join(" ") if message_text&.chars&.first == "@"
  end

  def process!
    raise NotImplementedError, "Subclasses must implement a 'handle' method"
  end

  def chat_id
    @message["chat"]["id"]
  end

  def message_id
    @message["message_id"]
  end

  def message_text
    @message["text"] || @message["caption"]
  end

  def message_text_down
    @message_text_down ||= message_text&.downcase
  end

  def words
    @words ||= message_text_down&.scan(/(?:[@#!]?\p{L}\p{M}*[\p{L}\p{M}\d]*)(?:-[\p{L}\p{M}\d]+)*/)
  end

  def user
    @user
  end

  def user_from
    @message["from"]
  end

  def user_to
    @message["reply_to_message"]["from"]
  end

  def user_link(user)
    first_name, last_name = user["first_name"], user["last_name"]
    "<a href='tg://user?id=#{user["id"]}'>#{last_name ? "#{first_name} #{last_name}" : first_name}</a>"
  end

  def message_from_su?
    @user.id == su_id
  end

  def su_id
    @su_id ||= Initializer.get_su_id
  end

  def bot_username
    @bot_username ||= @bot.getMe.username
  end

  def bot_url(param)
    "https://t.me/#{bot_username}?start=#{param}"
  end

  def channel_url
    @channel_url ||= "https://t.me/#{Initializer.get_channel_name}"
  end

  def callback_data
    @message["data"]&.split(":")
  end

  def send_message(chat_id, text)
    @bot.api.send_message(chat_id:, text:)
  end
end