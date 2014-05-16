module Translation
  module FlatHash
    class << self
      def to_flat_hash(hash)
        get_flat_hash_for_level(hash)
      end

      def to_hash(flat_hash)
        hash = {}

        flat_hash.each_pair do |key, value|
          key_parts = key.split('.')
          acc       = hash

          key_parts.each_with_index do |key_part, index|
            if index < key_parts.size - 1
              unless acc.has_key?(key_part)
                acc[key_part] = {}
              end

              acc = acc[key_part]
            else
              if key_part.end_with?(']')
                key_part_prefix = key_part.split('[').first
                item_index      = key_part.split('[').last.to_i

                unless acc.has_key?(key_part_prefix)
                  acc[key_part_prefix] = []
                end

                acc[key_part_prefix][item_index] = value
              else
                acc[key_part] = value
              end
            end
          end
        end

        return hash
      end

      def brol(source_hash, current_level_key = '', target_hash = {})
        key_parts = current_level_key.split('.')

        if key_parts.first.end_with?(']')
          # array
        else
          # hash
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
