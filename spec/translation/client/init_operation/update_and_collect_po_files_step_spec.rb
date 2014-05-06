require 'spec_helper'

describe Translation::Client::InitOperation::UpdateAndCollectPoFilesStep do

  it 'creates PO files when starting from blank slate' do
    target_locales = ['fr', 'nl']
    pot_path       = 'tmp/app.pot'
    locales_path   = 'tmp'

    pot_data = <<EOS
msgid "Hi kids, do you like violence ?"
msgstr ""

msgid "Let's get ready to rumble!"
msgstr ""
EOS

    File.open(pot_path, 'wb') do |file|
      file.write(pot_data)
    end

    operation_step = Translation::Client::InitOperation::UpdateAndCollectPoFilesStep.new(target_locales, pot_path, locales_path)
    operation_step.run

    File.read('tmp/fr/app.po').should == pot_data
    File.read('tmp/nl/app.po').should == pot_data

    operation_step.params["po_data_fr"].should == pot_data
    operation_step.params["po_data_nl"].should == pot_data
  end

end
