require 'spec_helper'

describe TranslationIO::Client::InitOperation::UpdatePotFileStep do

  it 'works' do
    pot_path     = 'tmp/test.pot'
    source_files = Dir['spec/support/**/*.{rb,erb}']
    params       = {}

    TranslationIO::Client::InitOperation::UpdatePotFileStep.new(pot_path, source_files).run(params)

    pot_data = <<EOS
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

    File.read('tmp/test.pot').should end_with pot_data
    params['pot_data'].should end_with pot_data                     # contains segments
    params['pot_data'].should start_with '# SOME DESCRIPTIVE TITLE' # also contains header
  end

 it 'works with custom POT config' do
    pot_path     = 'tmp/test.pot'
    source_files = Dir['spec/support/**/*.{rb,erb}']
    params       = {}

    TranslationIO.config.pot_msgid_bugs_address = 'newcontact@translation.io'
    TranslationIO.config.pot_package_name       = 'SuperProject'
    TranslationIO.config.pot_package_version    = '1.3.4'
    TranslationIO.config.pot_copyright_holder   = 'MegaCorporation'
    TranslationIO.config.pot_copyright_year     = 2025

    TranslationIO::Client::InitOperation::UpdatePotFileStep.new(pot_path, source_files).run(params)

    pot_data = <<EOS
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

    File.read('tmp/test.pot').should end_with pot_data
    params['pot_data'].should end_with pot_data                     # contains segments
    params['pot_data'].should start_with '# SOME DESCRIPTIVE TITLE' # also contains header
    params['pot_data'].should include    'newcontact@translation.io'
    params['pot_data'].should include    'SuperProject'
    params['pot_data'].should include    '1.3.4'
    params['pot_data'].should include    'MegaCorporation'
    params['pot_data'].should include    '2025'
  end

  it "Collects gettext keys from code" do
    pot_path     = 'tmp/test.pot'
    source_files = Dir['spec/support/**/*.{rb,erb}']

    step_operation = TranslationIO::Client::InitOperation::UpdatePotFileStep.new(pot_path, source_files)
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
