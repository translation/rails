# coding: utf-8

require 'spec_helper'
require 'action_view'

describe TranslationIO::Client::BaseOperation::DumpHamlGettextKeysStep do
  it do
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
  %p= np_("Fruit", "Apple", "%{num} Apples", 3) % { :num => 3 }
EOS
    end

    haml_source_files = [
      haml_path_1, haml_path_2
    ]

    operation = TranslationIO::Client::BaseOperation::DumpHamlGettextKeysStep.new(haml_source_files)

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
    File.read('tmp/translation/haml-gettext-00000013.rb').strip.should include('np_("Fruit", "Apple", "%{num} Apples", 3)')
  end
end
