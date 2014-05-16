require 'deep_merge/rails_compat'

module Translation
  module FlatHash
    class << self
      def to_flat_hash(hash)
        get_flat_hash_for_level(hash)
      end

      def to_hash(flat_hash)
        hash = {}

        flat_hash.each_pair do |key, value|
          hash.deeper_merge!( recursive_call(key, value))
        end

        new_hash = better(hash)

        new_hash
      end

      def better(hash_or_array)
        if hash_or_array.is_a? Hash
          if hash_or_array.keys[0] == '0' || hash_or_array.keys[0] == '1'
            a = hash_or_array.values.collect do |value|
              better(value)
            end
            puts a.inspect
            return a
          else
            a = {}
            hash_or_array.keys.each do |key|
              a.merge!( key => better(hash_or_array[key]) )
            end
            return a
          end
        elsif hash_or_array.is_a? Array
          a = []
          hash_or_array.each_with_index do |value, i|
            a << better(hash_or_array[i])
          end
          return a
        else
          return hash_or_array
        end
      end

      def recursive_call(key_string, value)
        if key_string == ''
          value
        elsif key_string[0] == '['
          array_pos = key_string.split(']', 2)[0]
          array_pos = array_pos.split('[', 2)[1]

          next_key  = key_string.split(']', 2).count == 2 ? key_string.split(']', 2)[1] : ""
          next_key = next_key[1..-1] if next_key[0] == '.'

          [array_pos => recursive_call(next_key, value)]
        elsif key_string[0] != '[' && (key_string.include?('.') or key_string.include?('['))
          new_key  = key_string.split(/\.|\[/, 2)[0]
          next_key = key_string.split(/\.|\[/, 2)[1]

          if next_key.count(']') > next_key.count('[')
            next_key = '[' + next_key
          end

          { new_key => recursive_call(next_key, value) }
        else
          { key_string => value }
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

#Translation::FlatHash.to_hash({
#  'en.hello'           => 'Hello world',
#  'en.main.menu.stuff' => 'This is stuff',
#  'fr.salut'           => 'blabla'
#})

#Translation::FlatHash.recursive_call('en.family[0][0]', 'Ta mère')
#Translation::FlatHash.recursive_call('en.family[0][1]', 'Ta soeur')
#Translation::FlatHash.recursive_call('en.family[1][0]', 'Ton père')
#Translation::FlatHash.recursive_call('en.family[1][1]', 'Ton frère')

Translation::FlatHash.better({ 'key'       => { "0" => [{"0" => "houh"}, {'1' => "blah"}],
                                                "1" => [{"0" => "hihi"}, {'1' => "haha"}] },
                               'other_key' => 'hello world' })
