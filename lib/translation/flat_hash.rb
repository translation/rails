module Translation
  module FlatHash
    class << self
      def to_flat_hash(hash)
        get_flat_hash_for_level(hash)
      end

      def to_hash(flat_hash)
        hash = {}

        flat_hash.each_pair do |key, value|
          recursive_call(hash, key, value)
        end

        hash
      end

      def recursive_call(hash, key_string, value)
        current_object = hash
        current_key    = key_string.split(/\.|\[/, 2)[0] # first is always a hash
        key_string     = key_string.split(/\.|\[/, 2)[1]

        if !key_string or key_string == '' # if only one key like { 'en' => 'salut' }
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

              if (current_object.is_a?(Hash) && !current_object.has_key?(current_key)) || !current_object[current_key]
                current_object[current_key] = []
              end

              current_object = current_object[current_key]
              current_key    = array_pos

              if key_string == ''
                current_object << value
              end
            # next is hash
            elsif key_string[0] != '[' && (key_string.include?('.') or key_string.include?('['))
              new_key    = key_string.split(/\.|\[/, 2)[0]
              key_string = key_string.split(/\.|\[/, 2)[1]

              # Put back '[' if needed
              if key_string.count(']') > key_string.count('[')
                key_string = '[' + key_string
              end

              if (current_object.is_a?(Hash) && !current_object.has_key?(current_key)) || !current_object[current_key]
                current_object[current_key] = {}
              end
              current_object = current_object[current_key]
              current_key    = new_key
            # next (last) is value
            else
              new_key = key_string

              if (current_object.is_a?(Hash) && !current_object.has_key?(current_key)) || !current_object[current_key]
                current_object[current_key] = {}
              end
              current_object          = current_object[current_key]
              current_object[new_key] = value

              key_string = ''
            end
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

#Translation::FlatHash.to_hash({ 'en.hello.salut' => 'Hello world' })
#Translation::FlatHash.to_hash({ 'en.main.menu.stuff' => 'This is stuff' })
#Translation::FlatHash.to_hash({ 'fr.salut' => 'blabla' })
#Translation::FlatHash.to_hash({ 'fr[0]' => 'blabla', })

#Translation::FlatHash.to_hash({ 'fr[0].bouh.salut' => 'blabla' })
#
#Translation::FlatHash.to_hash({
#  'en.hello.salut'     => 'Hello world',
#  'en.main.menu.stuff' => 'This is stuff',
#  'fr.salut'           => 'blabla'
#})



#Translation::FlatHash.to_hash({ 'fr[0][0].bouh.salut[0]'  => 'blabla',
#                                'fr[0][0].bouh.salut[1]'  => 'blibli',
#                                'fr[1][0].salut' => 'hahah',
#                                'fr[1][1].ha'    => 'maison' })

#Translation::FlatHash.to_hash({ 'en.hello.salut' => 'Hello world',
#                                'en.hello.haha'  => 'Bonjour monde',
#                                'fr.hello.haha'  => 'bonjour LE monde' })
#Translation::FlatHash.to_hash({ 'en.main.menu.stuff' => 'This is stuff' })
#Translation::FlatHash.to_hash({ 'fr.salut' => 'blabla' })

Translation::FlatHash.to_hash({ 'fr[0].bouh'  => 'blabla',
                                'fr[1].hello' => 'blibli'})

Translation::FlatHash.to_hash({ 'en[0][0]' => 'hello',
                                'en[0][1]' => 'new',
                                'en[0][2]' => 'world',
                                'en[1][0]' => 'salut' })

Translation::FlatHash.to_hash({ 'fr[0][0].bouh'  => 'blabla',
                                'fr[0][1].hello' => 'blibli',
                                'fr[1][0].salut' => 'hahah',
                                'fr[1][1].ha'    => 'maison' })
