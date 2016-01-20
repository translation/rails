require 'spec_helper'

describe TranslationIO::Content::Init do
  it 'works' do
    Post.create!({ :title_fr => 'Un super titre',       :content_fr => 'Un super contenu'       })
    Post.create!({ :title_fr => 'Un autre super titre', :content_fr => 'Un autre super contenu' })

    init = TranslationIO::Content::Init.new

    init.build_init_params.should == {
      "content_po_data_en" => "msgctxt \"Post-1-title\"\nmsgid \"Un super titre\"\nmsgstr \"\"\n\nmsgctxt \"Post-1-content\"\nmsgid \"Un super contenu\"\nmsgstr \"\"\n\nmsgctxt \"Post-2-title\"\nmsgid \"Un autre super titre\"\nmsgstr \"\"\n\nmsgctxt \"Post-2-content\"\nmsgid \"Un autre super contenu\"\nmsgstr \"\"\n",
      "content_po_data_nl" => "msgctxt \"Post-1-title\"\nmsgid \"Un super titre\"\nmsgstr \"\"\n\nmsgctxt \"Post-1-content\"\nmsgid \"Un super contenu\"\nmsgstr \"\"\n\nmsgctxt \"Post-2-title\"\nmsgid \"Un autre super titre\"\nmsgstr \"\"\n\nmsgctxt \"Post-2-content\"\nmsgid \"Un autre super contenu\"\nmsgstr \"\"\n"
    }

    init.stub(:run).and_return(true)
    init.run
  end
end
