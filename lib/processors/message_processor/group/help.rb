module MessageProcessor::Group
  class Help
    include ProcessorGroup
    include CommandParameters

    def responds?
      command == "help" || I18n.t("help.group.commands").include?(first_parameter)
    end

    def process!
      [{
         send_message: {
           chat_id:,
           text: I18n.t(
             "help.group.text",
             channel: "<a href='tg://resolve?domain=#{Initializer.get_channel_name}'>#{I18n.t("help.group.channel")}</a>"
           )
         }
      }]
    end
  end
end