module TranslationIO
  module Controller
    def set_locale
      requested_locale = params[:locale]                     ||
                         session[:locale]                    ||
                         cookies[:locale]                    ||
                         request.env['HTTP_ACCEPT_LANGUAGE'] ||
                         I18n.default_locale

      if I18n.available_locales.include?(requested_locale.to_sym)
        session[:locale] = requested_locale
        I18n.locale      = requested_locale
      else
        redirect_to :root, :locale => I18n.default_locale
      end
    end
  end
end
