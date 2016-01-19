require 'spec_helper'

describe TranslationIO::Content do
  it 'stores translated fields' do
    TranslationIO::Content.translated_fields.should == {
      'Post' => ['title', 'content']
    }
  end
end
