require 'spec_helper'

describe TranslationIO::Content::Storage::GlobalizeStorage do
  before :each do
    @article = Article.create!

    @article.set_translations({
      :fr => { :title => 'Titre' },
      :en => { :title => 'Title' },
      :nl => { :title => 'Naam'  }
    })

    @storage = TranslationIO::Content::Storage::GlobalizeStorage.new
  end

  it 'gets' do
    @storage.get('fr', @article, :title).should == 'Titre'
    @storage.get('en', @article, :title).should == 'Title'
    @storage.get('nl', @article, :title).should == 'Naam'
  end

  it 'sets' do
    @storage.set('fr', @article, :title, 'Nouveau titre')
    @storage.set('en', @article, :title, 'New title')
    @storage.set('nl', @article, :title, 'Niewe naam')

    @article.reload

    Globalize.with_locale(:fr) { @article.title.should == 'Nouveau titre' }
    Globalize.with_locale(:en) { @article.title.should == 'New title'     }
    Globalize.with_locale(:nl) { @article.title.should == 'Niewe naam'    }
  end
end
