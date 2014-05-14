require 'spec_helper'

describe Translation::Client::BaseOperation::SaveNewPoFilesStep do

  it do
    target_locales = ['fr', 'nl']
    locales_path   = 'tmp'

    parsed_response = {
      'po_data_fr' => '<GETTEXT DATA FR>',
      'po_data_nl' => '<GETTEXT DATA NL>'
    }

    operation_step = Translation::Client::BaseOperation::SaveNewPoFilesStep.new(target_locales, locales_path, parsed_response)
    operation_step.run

    File.read('tmp/fr/app.po').should == '<GETTEXT DATA FR>'
    File.read('tmp/nl/app.po').should == '<GETTEXT DATA NL>'
  end

end
