module ProcessorPrivate
  include Processor

  private

  def valentines_recipient
    @valentines_recipient ||= User.find_by(id: words[1]) if command == "start" && words[1].to_i != user.id
  end

  def private
    @chat
  end
end
