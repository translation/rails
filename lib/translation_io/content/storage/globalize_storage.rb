module TranslationIO
  module Content
    module Storage
      class GlobalizeStorage < BaseStorage
        def get(locale, instance, field_name)
          Globalize.with_locale(locale.to_sym) do
            instance.send(field_name.to_sym).to_s
          end
        end

        def set(locale, instance, field_name, value)
          instance.set_translations({
            locale => {
              field_name => value
            }
          })
        end
      end
    end
  end
end
