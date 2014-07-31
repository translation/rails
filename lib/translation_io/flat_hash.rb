module TranslationIO
  module FlatHash
    class << self
      def to_flat_hash(hash)
        get_flat_hash_for_level(hash)
      end

      def to_hash(flat_hash)
        hash = {}

        flat_hash.each_pair do |key, value|
          build_hash_with_flat(hash, key, value)
        end

        hash
      end

      private

      def build_hash_with_flat(hash, key_string, value)
        current_object = hash
        splitted       = key_string.split(/\.|\[/, 2)
        current_key    = splitted[0] # first is always a hash
        key_string     = splitted[1]

        if key_string.blank? # if only one key like { 'en' => 'salut' }
          current_object[current_key] = value
        else
          # Put back '[' if needed
          if key_string.count(']') > key_string.count('[')
            key_string = '[' + key_string
          end

          while key_string != ''
            # Next is array
            if key_string[0] == '['
              array_pos = key_string.split(']', 2)[0]
              array_pos = array_pos.split('[', 2)[1].to_i

              key_string = key_string.split(']', 2).count == 2 ? key_string.split(']', 2)[1] : ""
              key_string = key_string[1..-1] if key_string[0] == '.'

              if no_key?(current_object, current_key)
                current_object[current_key] = []
              end

              current_object = current_object[current_key]
              current_key    = array_pos

              # array is terminal
              if key_string == ''
                current_object[array_pos] = value
              end
            # next is hash
            elsif key_string[0] != '[' && (key_string.include?('.') or key_string.include?('['))
              splitted   = key_string.split(/\.|\[/, 2)
              new_key    = splitted[0]
              key_string = splitted[1]

              # Put back '[' if needed
              if key_string.count(']') > key_string.count('[')
                key_string = '[' + key_string
              end

              if no_key?(current_object, current_key)
                current_object[current_key] = {}
              end
              current_object = current_object[current_key]
              current_key    = new_key
            # next (last) is value
            else
              new_key = key_string

              if no_key?(current_object, current_key)
                current_object[current_key] = {}
              end
              current_object          = current_object[current_key]
              current_object[new_key] = value

              key_string = ''
            end
          end
        end
      end

      def no_key?(array_or_hash, key)
        (array_or_hash.is_a?(Hash) && !array_or_hash.has_key?(key)) || !array_or_hash[key]
      end

      def get_flat_hash_for_level(value, parent_key = nil)
        flat_hash = {}

        if value.is_a? Hash
          value.each_pair do |key, value|
            current_level_key = [ parent_key, key ].reject(&:blank?).join('.')
            flat_hash.merge!(get_flat_hash_for_level(value, current_level_key))
          end
        elsif value.is_a? Array
          value.each_with_index do |item, index|
            flat_hash.merge!(get_flat_hash_for_level(item, "#{parent_key}[#{index}]"))
          end
        else
          flat_hash[parent_key] = value
        end

        flat_hash
      end

    end
  end
end

