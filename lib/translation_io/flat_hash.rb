module TranslationIO
  module FlatHash
    class << self
      def to_flat_hash(hash)
        hash = brackets_to_joker!(hash)
        hash = remove_reserved_keys!(hash)
        get_flat_hash_for_level(hash)
      end

      def to_hash(flat_hash)
        hash = {}

        flat_hash.each_pair do |key, value|
          build_hash_with_flat(hash, key, value)
        end

        joker_to_brackets!(hash)
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
              current_object[new_key] = value if current_object.is_a?(Hash)

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

      def brackets_to_joker!(h)
        gsub_keys!(h, '[', ']', '<@~<', '>@~>')
      end

      def joker_to_brackets!(h)
        gsub_keys!(h, '<@~<', '>@~>', '[', ']')
      end

      def gsub_keys!(h, from_1, from_2, to_1, to_2)
        if h.is_a?(Hash)
          h.keys.each do |key|
            if key.to_s.include?(from_1) || key.to_s.include?(from_2)
              new_key = key.to_s.gsub(from_1, to_1).gsub(from_2, to_2)
            else
              new_key = key
            end
            h[new_key] = h.delete(key)
            gsub_keys!(h[new_key], from_1, from_2, to_1, to_2)
          end
        elsif h.respond_to?(:each)
          h.each { |e| gsub_keys!(e, from_1, from_2, to_1, to_2) }
        end
        h
      end

      def remove_reserved_keys!(h)
        if h.is_a?(Hash)
          h.keys.each do |key|
            if [TrueClass, FalseClass].include?(key.class)
              # # This warning is commented because Rails admin uses bad keys: https://github.com/sferik/rails_admin/blob/master/config/locales/rails_admin.en.yml
              # TranslationIO.info("Warning - We found some YAML protected keys in your project, they will not be synchronized: 'yes', 'no', 'y', 'n', 'on', 'off', 'true', 'false'")
              # TranslationIO.info(h.inspect)
              h.delete(key)
            else
              remove_reserved_keys!(h[key])
            end
          end
        elsif h.respond_to?(:each)
          h.each { |e| remove_reserved_keys!(e) }
        end
        h
      end
    end
  end
end

