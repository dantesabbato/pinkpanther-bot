require_relative "../../config/boot"

module InflectorService
  class << self
    def inflect(locale, word, count)
      inflections = I18n.t("inflections.#{word}", locale: locale, default: nil)
      return word unless inflections.is_a?(Hash)
      inflections[plural_key(locale, count).to_sym] || word
    end

    private

    def plural_key(locale, count)
      case locale
      when :ru
        return :many if (count % 100).between?(11, 14)
        case count % 10
        when 1 then :one
        when 2..4 then :few
        else :many
        end
      when :en
        count == 1 ? :one : :many
      else
        :many
      end
    end
  end
end