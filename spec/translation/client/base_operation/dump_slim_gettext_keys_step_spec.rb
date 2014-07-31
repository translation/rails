# coding: utf-8

require 'spec_helper'
require 'slim'

describe TranslationIO::Client::BaseOperation::DumpSlimGettextKeysStep do
  it do
    slim_path_1 = "tmp/#{Time.now.to_i}.haml"
    slim_path_2 = "tmp/#{Time.now.to_i}.html.haml"

    File.open(slim_path_1, 'w') do |file|
      file.puts <<EOS
p = _("I am a text from a SLIM file")
EOS
    end

    File.open(slim_path_2, 'w') do |file|
      file.puts <<EOS
doctype html
html
  head
    title Slim Examples
    meta name="keywords" content="template language"
    meta name="author" content=author
    javascript:
      alert('Slim supports embedded javascript!')

  body
    h1 = _("Title")

    #content
      p This example shows you how a basic Slim file looks like.

      == yield

      - unless items.empty?
        table
          - for item in items do
            tr
              td.name = item.name
              td.price = item.price
              td = _("I am a text")
      - else
        p
         | No items found.  Please add some inventory.
           Thank you!
        p = _("I am another text")
        p = n_("Un cheval", "%{num} chevaux", 42)

    div id="footer"
      = render 'footer'
      div = np_("Fruit", "Apple", "%{num} Apples", 3)
EOS
    end

    slim_source_files = [
      slim_path_1, slim_path_2
    ]

    operation = TranslationIO::Client::BaseOperation::DumpSlimGettextKeysStep.new(slim_source_files)

    operation.send(:extracted_gettext_entries).should == [
      '_("I am a text from a SLIM file"))',
      '_("Title"))',
      '_("I am a text"))',
      '_("I am another text"))',
      'n_("Un cheval", "%{num} chevaux", 42))',
      'np_("Fruit", "Apple", "%{num} Apples", 3))'
    ]

   operation.run

    File.read('tmp/translation-slim-gettext.rb').should == <<EOS
_("I am a text from a SLIM file"))
_("Title"))
_("I am a text"))
_("I am another text"))
n_("Un cheval", "%{num} chevaux", 42))
np_("Fruit", "Apple", "%{num} Apples", 3))
EOS
  end
end
