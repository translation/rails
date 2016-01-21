require 'spec_helper'

describe TranslationIO::Content::Storage::SuffixStorage do
  before :each do
    @post = Post.create!({
      :title_fr => 'Titre',
      :title_en => 'Title',
      :title_nl => 'Naam'
    })

    @storage = TranslationIO::Content::Storage::SuffixStorage.new
  end

  it 'gets' do
    @storage.get('fr', @post, :title).should == 'Titre'
    @storage.get('en', @post, :title).should == 'Title'
    @storage.get('nl', @post, :title).should == 'Naam'
  end

  it 'sets' do
    @storage.set('fr', @post, :title, 'Nouveau titre')
    @storage.set('en', @post, :title, 'New title')
    @storage.set('nl', @post, :title, 'Niewe naam')

    @post.reload

    @post.title_fr.should == 'Nouveau titre'
    @post.title_en.should == 'New title'
    @post.title_nl.should == 'Niewe naam'
  end
end
