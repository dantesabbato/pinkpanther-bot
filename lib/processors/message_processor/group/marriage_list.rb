# TODO: Group the list of weddings by anniversaries
module MessageProcessor::Group
  class MarriageList
    include ProcessorGroup

    def responds?
      super && I18n.t('marriage.list.commands').include?(message_text)
    end

    def process!
      pairs = Marriage.active
      result = if pairs.empty?
        I18n.t('marriage.list.empty')
      else
        I18n.t('marriage.list.head') +
          pairs.each_with_index.map { |pair, index|
            I18n.t(
              'marriage.list.row',
              number: index + 1,
              pair: "#{pair.first.link} + #{pair.second.link}",
              time: pair.duration
            )
          }.join("\n") +
          I18n.t('marriage.list.ground')
      end
      [{ send_message: { chat_id:, text: result } }]
    end
  end
end
