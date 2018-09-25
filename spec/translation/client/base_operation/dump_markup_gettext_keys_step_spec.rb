# coding: utf-8

require 'spec_helper'
require 'action_view'

describe TranslationIO::Client::BaseOperation::DumpMarkupGettextKeysStep do
  it 'works with HAML' do
    haml_path_1 = "tmp/#{Time.now.to_i}.haml"
    haml_path_2 = "tmp/#{Time.now.to_i}.html.haml"

    File.open(haml_path_1, 'w') do |file|
      file.puts <<EOS
%p= _("I am a text")
%p= _('I am another text')
EOS
    end

    File.open(haml_path_2, 'w') do |file|
      file.puts <<EOS
%section.container
  %h1= _("I am a text from a HAML file")

  %p= _("Hi kids. Do you like violence ?")

  %p= _("%{name} is dead") % { name: 'Dr Dre' }

  %p= n_("Apple", "%{num} Apples", 1)     % { :num => 1 }
  %p= n_(["Orange", "%{num} Oranges"], 1) % { :num => 1 }
  %p= n_("Apple", "%{num} Apples", 3)     % { :num => 3 }
  %p= n_(["Apple", "%{num} Apples"], 3)   % { :num => 3 }


  %p= p_("Printer", "Open") + ' - ' + p_("File", "Open")
  %p= s_("Printer|Open") + ' - ' + s_("File|Open")
  %p= cache("admin_nav_zone_\#{current_zone.try(:id)}_\#{params[:controller].parameterize("_")}_\#{Time.now.strftime("%Y%m%d%H%M").to_i / 5}") do
  %p= np_("Fruit", "Apple", "%{num} Apples", 3) % { :num => 3 }
EOS
    end

    haml_source_files = [
      haml_path_1, haml_path_2
    ]

    operation = TranslationIO::Client::BaseOperation::DumpMarkupGettextKeysStep.new(haml_source_files, :haml)

    operation.send(:extracted_gettext_entries).should == [
      '_("I am a text")',
      '_(\'I am another text\')',
      '_("I am a text from a HAML file")',
      '_("Hi kids. Do you like violence ?")',
      '_("%{name} is dead")',
      'n_("Apple", "%{num} Apples", 1)',
      'n_(["Orange", "%{num} Oranges"], 1)',
      'n_("Apple", "%{num} Apples", 3)',
      'n_(["Apple", "%{num} Apples"], 3)',
      'p_("Printer", "Open")',
      'p_("File", "Open")',
      's_("Printer|Open")',
      's_("File|Open")',
      '_")}_#{Time.now.strftime("',                  # SYNTAX INVALID! Wrong parsing
      'np_("Fruit", "Apple", "%{num} Apples", 3)'
    ]

    operation.run

    File.read('tmp/translation/haml-gettext-00000000.rb').strip.should include('_("I am a text")')
    File.read('tmp/translation/haml-gettext-00000001.rb').strip.should include("_('I am another text')")
    File.read('tmp/translation/haml-gettext-00000002.rb').strip.should include('_("I am a text from a HAML file")')
    File.read('tmp/translation/haml-gettext-00000003.rb').strip.should include('_("Hi kids. Do you like violence ?")')
    File.read('tmp/translation/haml-gettext-00000004.rb').strip.should include('_("%{name} is dead")')
    File.read('tmp/translation/haml-gettext-00000005.rb').strip.should include('n_("Apple", "%{num} Apples", 1)')
    File.read('tmp/translation/haml-gettext-00000006.rb').strip.should include('n_(["Orange", "%{num} Oranges"], 1)')
    File.read('tmp/translation/haml-gettext-00000007.rb').strip.should include('n_("Apple", "%{num} Apples", 3)')
    File.read('tmp/translation/haml-gettext-00000008.rb').strip.should include('n_(["Apple", "%{num} Apples"], 3)')
    File.read('tmp/translation/haml-gettext-00000009.rb').strip.should include('p_("Printer", "Open")')
    File.read('tmp/translation/haml-gettext-00000010.rb').strip.should include('p_("File", "Open")')
    File.read('tmp/translation/haml-gettext-00000011.rb').strip.should include('s_("Printer|Open")')
    File.read('tmp/translation/haml-gettext-00000012.rb').strip.should include('s_("File|Open")')
    File.exist?('tmp/translation/haml-gettext-00000013.rb').should == false # because syntax invalid and file ignored
    File.read('tmp/translation/haml-gettext-00000014.rb').strip.should include('np_("Fruit", "Apple", "%{num} Apples", 3)')
  end

  it 'works with SLIM' do
    slim_path_1 = "tmp/#{Time.now.to_i}.slim"
    slim_path_2 = "tmp/#{Time.now.to_i}.html.slim"

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
              td = _("I am a (text)(text)")
      - else
        p
         | No items found.  Please add some inventory.
           Thank you!
        p = _("I am another text")
        p = n_("Un cheval", "%{num} chevaux", 42)
        p - cache("admin_nav_zone_\#{current_zone.try(:id)}_\#{params[:controller].parameterize("_")}_\#{Time.now.strftime("%Y%m%d%H%M").to_i / 5}") do
        p = np_("Fruit", "Apple", "%{num} (App)les", 3)

    div id="footer"
      = render 'footer'
      div = np_("Fruit", "Apple", "%{num} Apples", 3)
EOS
    end

    slim_source_files = [
      slim_path_1, slim_path_2
    ]

    operation = TranslationIO::Client::BaseOperation::DumpMarkupGettextKeysStep.new(slim_source_files, :slim)

    operation.send(:extracted_gettext_entries).should == [
      '_("I am a text from a SLIM file")',
      '_("Title")',
      '_("I am a text")',
      '_("I am a (text)(text)")',
      '_("I am another text")',
      'n_("Un cheval", "%{num} chevaux", 42)',
      '_")}_#{Time.now.strftime("',                  # SYNTAX INVALID! Wrong parsing
      'np_("Fruit", "Apple", "%{num} (App)les", 3)',
      'np_("Fruit", "Apple", "%{num} Apples", 3)'
    ]

    operation.run

    File.read('tmp/translation/slim-gettext-00000000.rb').strip.should include('_("I am a text from a SLIM file")')
    File.read('tmp/translation/slim-gettext-00000001.rb').strip.should include('_("Title")')
    File.read('tmp/translation/slim-gettext-00000002.rb').strip.should include('_("I am a text")')
    File.read('tmp/translation/slim-gettext-00000003.rb').strip.should include('_("I am a (text)(text)")')
    File.read('tmp/translation/slim-gettext-00000004.rb').strip.should include('_("I am another text")')
    File.read('tmp/translation/slim-gettext-00000005.rb').strip.should include('n_("Un cheval", "%{num} chevaux", 42)')
    File.exist?('tmp/translation/slim-gettext-00000006.rb').should == false # because syntax invalid and file ignored
    File.read('tmp/translation/slim-gettext-00000007.rb').strip.should include('np_("Fruit", "Apple", "%{num} (App)les", 3)')
    File.read('tmp/translation/slim-gettext-00000008.rb').strip.should include('np_("Fruit", "Apple", "%{num} Apples", 3)')
  end
end
