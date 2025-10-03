module CommandParameters
  private

  def anchor_command?
  end

  def command_parameters
    @command_parameters ||= words.drop(1) if I18n.t("bot.anchor").include?(words&.first)
  end

  def first_parameter
    @first_parameter ||= command_parameters[0] if command_parameters
  end

  def second_parameter
    @second_parameter ||= command_parameters[1..] if command_parameters
  end
end