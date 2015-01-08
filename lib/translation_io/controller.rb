module TranslationIO
  module Controller
    def set_locale
      requested_locale = params[:locale]                                             ||
                         session[:locale]                                            ||
                         cookies[:locale]                                            ||
                         extract_browser_locale(request.env['HTTP_ACCEPT_LANGUAGE']) ||
                         I18n.default_locale

      if I18n.available_locales.include?(requested_locale.to_sym)
        session[:locale] = requested_locale
        I18n.locale      = requested_locale
      else
        if respond_to?(:root_path)
          redirect_to root_path(:locale => I18n.default_locale)
        else
          redirect_to "/?locale=#{I18n.default_locale}"
        end
      end
    end

    def extract_browser_locale(http_accept_language)
      http_accept_language.to_s.scan(/[a-z]{2}(?:-[A-Z]{2})?/).detect do |candidate|
        I18n.available_locales.include?(candidate.to_sym)
      end
    end
  end
end
