require 'spec_helper'

describe Translation::Client::SyncOperation::SaveNewPoFilesStep do
  it do
    target_locales = ['fr', 'nl']
    locales_path   = 'tmp/config/locales/gettext'

    po_data_fr = '<some gettext data fr>'
    po_data_nl = '<some gettext data nl>'

    parsed_response = {
      'po_data_fr' => po_data_fr,
      'po_data_nl' => po_data_nl
    }

    step_operation = Translation::Client::SyncOperation::SaveNewPoFilesStep.new(target_locales, locales_path, parsed_response)
    step_operation.run

    File.read('tmp/config/locales/gettext/fr/app.po').should == '<some gettext data fr>'
    File.read('tmp/config/locales/gettext/nl/app.po').should == '<some gettext data nl>'
  end
end
