# TODO: 1) статус участника для каждой группы;
module MessageProcessor::Private
  class GroupList
    include ProcessorPrivate

    def responds?
      command == "groups" || I18n.t("groups.list.commands").include?(message_text)
    end

    def process!
      text = ""
      if message_from_su?
        groups = Group.all
        text += I18n.t("groups.list.head_extra")
        groups.each_with_index do |group, index|
          count = unless group.member_count.nil?
            "- " + group.member_count.to_s + " " + InflectorService.inflect(:ru, "members", group.member_count)
          end
          text += I18n.t(
            "groups.list.row_extra",
            number: index + 1,
            status: group.status_icon,
            group: group.link,
            count: count
          )
        end
      else
        groups = Group.includes(:members).where(members: { user_id: @message["from"]["id"] }).distinct
        text += I18n.t("groups.list.head")
        groups.each_with_index do |group, index|
          count = unless group.member_count.nil?
            "- " + group.member_count.to_s + " " + InflectorService.inflect(:ru, "members", group.member_count)
          end
          text += I18n.t(
            "groups.list.row",
            number: index + 1,
            group: group.link,
            count: count.to_s + " " + InflectorService.inflect(:ru, "members", count)
          )
        end
      end
      Initializer.get_logger.debug "TEXT: #{text}"
      [{ send_message: { chat_id: @message["chat"]["id"], text: text } }]
    end
  end
end