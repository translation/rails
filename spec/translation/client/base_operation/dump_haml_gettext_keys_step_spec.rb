# coding: utf-8

require 'spec_helper'
require 'action_view'
require 'haml'

describe Translation::Client::BaseOperation::DumpHamlGettextKeysStep do
  it do
    haml_path_1 = "tmp/#{Time.now.to_i}.haml"
    haml_path_2 = "tmp/#{Time.now.to_i}.html.haml"

    File.open(haml_path_1, 'w') do |file|
      file.puts <<EOS
%p= _("I am a text")
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


  %p= p_("Printer", "Open") + ' — ' + p_("File", "Open")
  %p= s_("Printer|Open") + ' — ' + s_("File|Open")
  %p= np_("Fruit", "Apple", "%{num} Apples", 3) % { :num => 3 }
EOS
    end

    haml_source_files = [
      haml_path_1, haml_path_2
    ]

    operation = Translation::Client::BaseOperation::DumpHamlGettextKeysStep.new(haml_source_files)

    operation.send(:extracted_gettext_entries).should == [
      '_("I am a text")',
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

    File.read('tmp/translation-haml-gettext.rb').should == <<EOS
_("I am a text")
_("I am a text from a HAML file")
_("Hi kids. Do you like violence ?")
_("%{name} is dead")
n_("Apple", "%{num} Apples", 1)
n_(["Orange", "%{num} Oranges"], 1)
n_("Apple", "%{num} Apples", 3)
n_(["Apple", "%{num} Apples"], 3)
p_("Printer", "Open")
p_("File", "Open")
s_("Printer|Open")
s_("File|Open")
np_("Fruit", "Apple", "%{num} Apples", 3)
EOS
  end
end
