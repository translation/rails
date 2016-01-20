require 'spec_helper'

describe TranslationIO::Content::Sync do
  describe '#apply_source_edits' do
    it 'works' do
      Post.create!({ :title_fr => 'Un super titre'                                  })
      Post.create!({ :title_fr => 'Un autre super titre'                            })
      Post.create!({ :title_fr => 'Encore un autre super titre qui a changé depuis' })

      sync = TranslationIO::Content::Sync.new

      backend_response = {
        "project_name"           => "WHATEVER",
        "project_url"            => "WHATEVER",
        "last_content_synced_at" => 1453132390,

        "content_source_edits" => [
          { "key" => "Post-1-title", "old_text" => "Un super titre",              "new_text" => "Un super titre modifié"       },
          { "key" => "Post-2-title", "old_text" => "Un autre super titre",        "new_text" => "Un autre super titre modifié" },
          { "key" => "Post-3-title", "old_text" => "Encore un autre super titre", "new_text" => "Encore un autre super titre modifié" },
        ]
      }

      sync.apply_source_edits(backend_response)

      Post.find(1).title_fr.should  == "Un super titre modifié"
      Post.find(2).title_fr.should  == "Un autre super titre modifié"
      Post.find(3).title_fr.should  == "Encore un autre super titre qui a changé depuis"
    end
  end

  describe '#build_local_changes_params' do

  end

  describe '#apply_new_translations_from_backend' do

  end
end
