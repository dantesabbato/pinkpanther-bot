# Processor responsible for displaying the list of group admins excluding bots
module MessageProcessor::Group
  class Admins
    include ProcessorGroup

    def responds?
      super && (command == "admins" || I18n.t("admins.commands").include?(message_text))
    end

    def process!
      text = I18n.t("admins.text.head")
      admins.each do |admin|
        text += I18n.t(
          "admins.text.row",
          user: admin.user.link,
          status: admin.status == "creator" ? I18n.t("admins.text.major") : ""
        )
      end
      [{ send_message: { chat_id:, text: } }]
    end
  end
end