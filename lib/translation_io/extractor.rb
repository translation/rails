module TranslationIO
  module Extractor

    GETTEXT_ENTRY_RE = Regexp.new('(?:' + TranslationIO::GETTEXT_METHODS.join('|') + ')\(\[?(?:".+?"(?:\s*,\s*)?)+\]?(?:[^)]*)?\)')

    def self.extract(code_to_parse)
      code_to_parse.scan(GETTEXT_ENTRY_RE)
    end
  end
end

# def extract_line(line)
#   entries = []

#   sorted_gettext_methods = [
#     :gettext, :sgettext, :ngettext, :nsgettext, :pgettext, :npgettext,
#     :np_, :ns_, :Nn_, :n_, :p_, :s_, :N_, :_
#   ]

#   sorted_gettext_methods.each do |method|
#     if index = line.index("#{method}(")
#       pos = index + "#{method}(".length
#       if line[pos] == '"' || ("#{method}"[0] == 'n' && line[pos] == '[')
#         end_pos = line[index...-1].index(')')
#         entries << line[index...index+end_pos+1]
#         entries += extract_line(line[index+end_pos+1...-1] + "\n")
#         break
#       end
#     end
#   end

#   return entries
# end
