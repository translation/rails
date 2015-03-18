require 'spec_helper'

describe TranslationIO::Client::SyncOperation::UpdateAndCollectPotFileStep do

  it "Collects gettext keys from code" do
    pot_path     = 'tmp/test.pot'
    source_files = Dir['spec/support/**/*.{rb,erb}']

    step_operation = TranslationIO::Client::SyncOperation::UpdateAndCollectPotFileStep.new(pot_path, source_files)
    params = {}
    step_operation.run(params)

    params['pot_data'].should end_with <<EOS
#: ../spec/support/rails_app/app/models/fake_model.rb:3
msgid "Hi kids, do you like violence ?"
msgstr ""

#: ../spec/support/rails_app/app/views/layouts/application.html.erb:1
msgid "Let's get ready to rumble!"
msgstr ""

#: ../spec/support/rails_app/app/views/layouts/application.html.erb:2
msgctxt "contexte"
msgid "salut"
msgstr ""

#: ../spec/support/rails_app/tmp/translation/haml-gettext-00000000.rb:1
msgctxt "Printer"
msgid "Open"
msgstr ""
EOS
  end

end
