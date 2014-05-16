module Translation
  module FlatHash
    class << self
      def to_flat_hash(hash)
        get_flat_hash_for_level(hash)
      end

      def to_hash(flat_hash)
        hash = {}

        flat_hash.each_pair do |key, value|
          recursive_call(hash, nil, key, value)
          puts hash
        end

        hash
      end

      def recursive_call(current_object, current_key, key_string, value)
        if key_string == ''
          if current_object.is_a? Hash
            current_object[current_key] = value
          elsif current_object.is_a? Array
            current_object << value
          end
        elsif key_string[0] == '['
          array_pos = key_string.split(']', 2)[0]
          array_pos = array_pos.split('[', 2)[1]

          next_key  = key_string.split(']', 2).count == 2 ? key_string.split(']', 2)[1] : ""
          next_key = next_key[1..-1] if next_key[0] == '.'

          if current_object.is_a? Hash
            current_object[current_key] = []
            recursive_call(current_object[current_key], nil, next_key, value)
          elsif current_object.is_a? Array
            current_object << []
            recursive_call(current_object.last, nil, next_key, value)
          end
        elsif key_string[0] != '[' && (key_string.include?('.') or key_string.include?('['))
          new_key  = key_string.split(/\.|\[/, 2)[0]
          next_key = key_string.split(/\.|\[/, 2)[1]

          if next_key.count(']') > next_key.count('[')
            next_key = '[' + next_key
          end

          if current_object.is_a? Hash
            current_object[current_key] = { new_key => '' }
            recursive_call(current_object[current_key], new_key, next_key, value)
          elsif current_object.is_a? Array
            current_object << [ { new_key => '' } ]
            recursive_call(current_object.last, new_key, next_key, value)
          end
        else
          if current_object.is_a? Hash
            current_object[current_key] = { key_string => value }
          elsif current_object.is_a? Array
            current_object << { key_string => value }
          end
        end
      end

      private

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

Translation::FlatHash.to_hash({
  'en.hello[1].salut'  => 'Hello world',
  'en.main.menu.stuff' => 'This is stuff',
  'fr.salut'           => 'blabla'
})

