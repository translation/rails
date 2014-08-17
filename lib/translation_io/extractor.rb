module TranslationIO
  module Extractor
    # visual:                          https://www.debuggex.com/r/fYSQ-jwQfTjhhE6T
    # .*? is non-greedy (lazy) match : http://stackoverflow.com/a/1919995/1243212
    REGEXP_INSIDE_1   = '\s*(?:\[?(?:(?:(?:".*?")|(?:\'.*?\'))\s*?,?\s*?){1}\]?),?\s*?.*?\s*'
    REGEXP_INSIDE_2   = '\s*(?:\[?(?:(?:(?:".*?")|(?:\'.*?\'))\s*?,?\s*?){2}\]?),?\s*?.*?\s*'
    REGEXP_INSIDE_3   = '\s*(?:\[?(?:(?:(?:".*?")|(?:\'.*?\'))\s*?,?\s*?){3}\]?),?\s*?.*?\s*'

    REGEXP_1 = '(?:sgettext|gettext|N_|s_|_)\s*(?:\('                  + REGEXP_INSIDE_1 + '\)|' + REGEXP_INSIDE_1 + ')'
    REGEXP_2 = '(?:nsgettext|ngettext|pgettext|ns_|Nn_|n_|p_)\s*(?:\(' + REGEXP_INSIDE_2 + '\)|' + REGEXP_INSIDE_2 + ')'
    REGEXP_3 = '(?:npgettext|np_)\s*(?:\('                             + REGEXP_INSIDE_3 + '\)|' + REGEXP_INSIDE_3 + ')'

    GETTEXT_REGEXP = Regexp.new('(?:' + REGEXP_3 + '|' + REGEXP_2 + '|' + REGEXP_1 + ')')

    def self.extract(code_to_parse)
      code_to_parse.scan(GETTEXT_REGEXP)
    end
  end
end

