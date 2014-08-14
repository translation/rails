require 'spec_helper'

describe TranslationIO::Extractor do
  describe '#describe' do

    it 'extracts empty inputs' do
      subject.extract('').should == []
    end

    context 'Double quotes' do
      it 'extracts singular gettext calls' do
        subject.extract('_("Hi kids !")').should == ["_(\"Hi kids !\")"]
      end

      it 'extracts singular gettext calls (with context)' do
        subject.extract('p_("menu", "Hi kids !")').should == ["p_(\"menu\", \"Hi kids !\")"]
      end

      it 'extracts plural gettext calls' do
        subject.extract('n_("Hi kid !", "Hi kids !", 42)').should == ["n_(\"Hi kid !\", \"Hi kids !\", 42)"]
      end

      it 'extracts plural gettext calls (with context)' do
        subject.extract('np_("menu", "Hi kid !", "Hi kids !", 42)').should == ["np_(\"menu\", \"Hi kid !\", \"Hi kids !\", 42)"]
      end

      it 'extracts singular gettext calls containing quotes' do
        subject.extract('_("Hi \"kids\" !")').should == ["_(\"Hi \\\"kids\\\" !\")"]
      end

      it 'extracts singular gettext calls containing brackets' do
        subject.extract('_("Hi (kids) !")').should == ["_(\"Hi (kids) !\")"]
      end
    end

    context 'Single quotes' do
      # not supported yet
    end

  end
end
