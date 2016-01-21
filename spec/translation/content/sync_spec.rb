require 'spec_helper'

describe TranslationIO::Content::Sync do
  describe '#apply_source_edits' do
    it 'works', :focus => true do
      post1 = Post.create!({ :title_fr => 'Un super titre'                                  })
      post2 = Post.create!({ :title_fr => 'Un autre super titre'                            })
      post3 = Post.create!({ :title_fr => 'Encore un autre super titre qui a changé depuis' })

      sync = TranslationIO::Content::Sync.new

      backend_response = {
        "content_source_edits" => [
          { "key" => "Post-#{post1.id}-title", "old_text" => "Un super titre",              "new_text" => "Un super titre modifié"              },
          { "key" => "Post-#{post2.id}-title", "old_text" => "Un autre super titre",        "new_text" => "Un autre super titre modifié"        },
          { "key" => "Post-#{post3.id}-title", "old_text" => "Encore un autre super titre", "new_text" => "Encore un autre super titre modifié" },
        ]
      }

      sync.apply_source_edits(backend_response)

      post1.reload
      post2.reload
      post3.reload

      post1.title_fr.should  == "Un super titre modifié"
      post2.title_fr.should  == "Un autre super titre modifié"
      post3.title_fr.should  == "Encore un autre super titre qui a changé depuis"
    end
  end

  describe '#build_local_changes_params' do
    it 'works' do
      post1 = Post.create!({ :title_fr => 'Un super titre modifé après le timestamp', :updated_at => 10.minutes.ago })
      post2 = Post.create!({ :title_fr => 'Un autre super titre modifé'  })
      post3 = Post.create!({ :title_fr => 'Un autre super titre modifié' })

      sync = TranslationIO::Content::Sync.new
      backend_response = sync.build_local_changes_params(Time.now.to_i)

      backend_response.should == {
        "content_pot_data" => "msgctxt \"Post-#{post2.id}-title\"\nmsgid \"Un autre super titre modifé\"\nmsgstr \"\"\n\nmsgctxt \"Post-#{post3.id}-title\"\nmsgid \"Un autre super titre modifié\"\nmsgstr \"\"\n"
      }
    end
  end

  describe '#apply_new_translations_from_backend' do
    it 'works' do
      post1 = Post.create!({ :title_fr => 'Un super titre',                              :title_en => 'An fucked up initial translation' })
      post2 = Post.create!({ :title_fr => 'Un autre super titre',                        :title_en => ''                                 })
      post3 = Post.create!({ :title_fr => 'Un autre super titre qui n\'aura pas changé', :title_en => ''                                 })

      backend_response = {
        "content_po_data_en" => "msgctxt \"Post-#{post1.id}-title\"\nmsgid \"Un super titre\"\nmsgstr \"An awesome title\"\n\nmsgctxt \"Post-#{post2.id}-title\"\nmsgid \"Un autre super titre\"\nmsgstr \"Another awesome title\"\n"
      }

      sync = TranslationIO::Content::Sync.new
      sync.apply_new_translations_from_backend(backend_response)

      post1.reload
      post2.reload
      post3.reload

      post1.title_en.should == 'An awesome title'
      post2.title_en.should == 'Another awesome title'
      post3.title_en.should == ''
    end
  end
end
