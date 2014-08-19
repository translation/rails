module TranslationIO
  module Extractor
    # visual:                          https://www.debuggex.com/r/fYSQ-jwQfTjhhE6T
    # .*? is non-greedy (lazy) match : http://stackoverflow.com/a/1919995/1243212
    REGEXP_INSIDE_1  = '\s*(?:\[?(?:(?:(?:".*?")|(?:\'.*?\'))\s*?,?\s*?){1}\]?)\s*?'
    REGEXP_INSIDE_2  = '\s*(?:\[?(?:(?:(?:".*?")|(?:\'.*?\'))\s*?,?\s*?){2}\]?),?\s*?.*?\s*'
    REGEXP_INSIDE_2B = '\s*(?:\[?(?:(?:(?:".*?")|(?:\'.*?\'))\s*?,?\s*?){2}\]?)\s*?'
    REGEXP_INSIDE_3  = '\s*(?:\[?(?:(?:(?:".*?")|(?:\'.*?\'))\s*?,?\s*?){3}\]?),?\s*?.*?\s*'

    REGEXP_1  = '(?:sgettext|gettext|N_|s_|_)\s*(?:\('      + REGEXP_INSIDE_1  + '\)|' + REGEXP_INSIDE_1  + ')'
    REGEXP_2  = '(?:nsgettext|ngettext|ns_|Nn_|n_)\s*(?:\(' + REGEXP_INSIDE_2  + '\)|' + REGEXP_INSIDE_2  + ')'
    REGEXP_2B = '(?:pgettext|p_)\s*(?:\('                   + REGEXP_INSIDE_2B + '\)|' + REGEXP_INSIDE_2B + ')'
    REGEXP_3  = '(?:npgettext|np_)\s*(?:\('                 + REGEXP_INSIDE_3  + '\)|' + REGEXP_INSIDE_3  + ')'

    GETTEXT_REGEXP = Regexp.new('(?:' + REGEXP_3 + '|' + REGEXP_2B + '|' + REGEXP_2 + '|' + REGEXP_1 + ')')

    def self.extract(code_to_parse)
      code_to_parse.scan(GETTEXT_REGEXP)
    end
  end
end

