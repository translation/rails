require 'spec_helper'

describe Translation::Client::SyncOperation::UpdatePotFileStep do

  it do
    pot_path     = 'tmp/test.pot'
    source_files = Dir['spec/support/**/*.{rb,erb}']

    step_operation = Translation::Client::SyncOperation::UpdatePotFileStep.new(pot_path, source_files)
    step_operation.run

    step_operation.params['pot_data'].should end_with <<EOS
#: ../spec/support/rails_app/app/models/fake_model.rb:3
msgid "Hi kids, do you like violence ?"
msgstr ""

#: ../spec/support/rails_app/app/views/layouts/application.html.erb:1
msgid "Let's get ready to rumble!"
msgstr ""
EOS
  end

end
