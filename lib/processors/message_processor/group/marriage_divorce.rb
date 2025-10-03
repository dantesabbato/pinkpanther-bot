# TODO: Add a callback for divorce confirmation
module MessageProcessor::Group
  class MarriageDivorce
    include ProcessorGroup

    def responds?
      super && I18n.t("marriage.divorce.commands").include?(message_text)
    end

    def process!
      dissolved_marriage = Marriage.find_marriage(@user.id)&.divorce
      [{
        send_message: {
          chat_id:,
          text: I18n.t(
            "marriage.divorce.#{dissolved_marriage ? 'text' : 'text_failure'}",
            user1: dissolved_marriage&.partner(@user.id)&.link,
            user2: @user.link,
            duration: dissolved_marriage&.duration
          )
        }
      }]
    end
  end
end
