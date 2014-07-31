require 'spec_helper'

describe TranslationIO::Client::InitOperation::UpdatePotFileStep do

  it do
    pot_path     = 'tmp/test.pot'
    source_files = Dir['spec/support/**/*.{rb,erb}']

    TranslationIO::Client::InitOperation::UpdatePotFileStep.new(pot_path, source_files).run

    File.read('tmp/test.pot').should end_with <<EOS
#: ../spec/support/rails_app/app/models/fake_model.rb:3
msgid "Hi kids, do you like violence ?"
msgstr ""

#: ../spec/support/rails_app/app/views/layouts/application.html.erb:1
msgid "Let's get ready to rumble!"
msgstr ""
EOS
  end

end
