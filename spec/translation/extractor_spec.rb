require 'spec_helper'

describe TranslationIO::Extractor do
  describe '#extract' do

    it 'extracts empty inputs' do
      subject.extract('').should == []
    end

    context 'Main operations - ' do
      it 'extracts gettext' do
        extracted = subject.extract('%div= gettext("Hi kids !")')
        extracted.should == ['gettext("Hi kids !")']
      end

      it 'extracts sgettext' do
        extracted = subject.extract('%div= sgettext("welcome|Hi kids !")')
        extracted.should == ['sgettext("welcome|Hi kids !")']
      end

      it 'extracts ngettext' do
        extracted = subject.extract('%div= ngettext("Hi kid !", "Hi kids !", 1)')
        extracted.should == ['ngettext("Hi kid !", "Hi kids !", 1)']
      end

      it 'extracts nsgettext' do
        extracted = subject.extract('%div= nsgettext("welcome|Hi kid !", "Hi kids !", 1)')
        extracted.should == ['nsgettext("welcome|Hi kid !", "Hi kids !", 1)']
      end

      it 'extracts pgettext' do
        extracted = subject.extract('%div= pgettext("welcome", "Hi kids !")')
        extracted.should == ['pgettext("welcome", "Hi kids !")']
      end

      it 'extracts npgettext' do
        extracted = subject.extract('%div= npgettext("welcome", "Hi kid !", "Hi kids !", 3)')
        extracted.should == ['npgettext("welcome", "Hi kid !", "Hi kids !", 3)']
      end

      it 'extracts np_' do
        extracted = subject.extract('%div= np_("welcome", "Hi kid !", "Hi kids !", 3)')
        extracted.should == ['np_("welcome", "Hi kid !", "Hi kids !", 3)']
      end

      it 'extracts ns_' do
        extracted = subject.extract('%div= ns_("welcome|Hi kid !", "Hi kids !", 1)')
        extracted.should == ['ns_("welcome|Hi kid !", "Hi kids !", 1)']
      end

      it 'extracts Nn_' do
        extracted = subject.extract('%div= Nn_("Hi kid !", "Hi kids !")')
        extracted.should == ['Nn_("Hi kid !", "Hi kids !")']
      end

      it 'extracts n_' do
        extracted = subject.extract('%div= n_("Hi kid !", "Hi kids !", 1)')
        extracted.should == ['n_("Hi kid !", "Hi kids !", 1)']
      end

      it 'extracts p_' do
        extracted = subject.extract('%div= p_("welcome", "Hi kids !")')
        extracted.should == ['p_("welcome", "Hi kids !")']
      end

      it 'extracts s_' do
        extracted = subject.extract('%div= s_("welcome|Hi kids !")')
        extracted.should == ['s_("welcome|Hi kids !")']
      end

      it 'extracts N_' do
        extracted = subject.extract('%div= N_("Hi kids !")')
        extracted.should == ['N_("Hi kids !")']
      end

      it 'extracts _' do
        extracted = subject.extract('%div= _("Hi kids !")')
        extracted.should == ['_("Hi kids !")']
      end

      it 'extracts n_ with square brackets' do
        extracted = subject.extract('%div= n_(["Apple", "%{num} Apples"], 3)')
        extracted.should == ['n_(["Apple", "%{num} Apples"], 3)']
      end

      it 'extracts np_ with square brackets' do
        extracted = subject.extract('%div= np_(["Fruit","Apple","%{num} Apples"], 3)')
        extracted.should == ['np_(["Fruit","Apple","%{num} Apples"], 3)']
      end

      it 'extracts ns_ with square brackets' do
        extracted = subject.extract('%div= ns_(["Fruit|Apple","%{num} Apples"], 3)')
        extracted.should == ['ns_(["Fruit|Apple","%{num} Apples"], 3)']
      end
    end

    context 'mixed quotes - ' do
      it 'extract _ with single quotes' do
        extracted = subject.extract("%div= _('Hi kids !')")
        extracted.should == ["_('Hi kids !')"]
      end

      it 'extracts n_ with mixed quotes' do
        extracted = subject.extract('%div= n_("Hi kid !", \'Hi kids !\', 42)')
        extracted.should == ['n_("Hi kid !", \'Hi kids !\', 42)']
      end

      it 'extracts n_ with mixed quotes (inverted)' do
        extracted = subject.extract('%div= n_(\'Hi kid !\', "Hi kids !", 42)')
        extracted.should == ['n_(\'Hi kid !\', "Hi kids !", 42)']
      end

      it 'extracts ns_ with square brackets and mixed quotes' do
        extracted = subject.extract('%div= ns_(["Fruit|Apple",\'%{num} Apples\'], 3)')
        extracted.should == ['ns_(["Fruit|Apple",\'%{num} Apples\'], 3)']
      end

      it 'extracts ns_ with square brackets and mixed quotes (inverted)' do
        extracted = subject.extract('%div= ns_([\'Fruit|Apple\',"%{num} Apples"], 3)')
        extracted.should == ['ns_([\'Fruit|Apple\',"%{num} Apples"], 3)']
      end
    end

    context 'brackets - ' do
      it 'extracts singular gettext call containing brackets' do
        extracted = subject.extract('%div= _("Hi (kids) !")')
        extracted.should == ['_("Hi (kids) !")']
      end

      it 'extracts singular gettext call containing opening bracket' do
        extracted = subject.extract('%div= _("Hi (kids) !")')
        extracted.should == ['_("Hi (kids) !")']
      end

      it 'extracts singular gettext call containing closing bracket' do
        extracted = subject.extract('%div= _("Hi kids) !")')
        extracted.should == ['_("Hi kids) !")']
      end

      it "extracts complex gettext call containing brackets" do
        extracted = subject.extract('%div= np_("Fruit", "Apple", "%{num} (App)les", 3)')
        extracted.should == ['np_("Fruit", "Apple", "%{num} (App)les", 3)']
      end
    end

    context 'multiline - ' do
      it 'extracts multiline text' do
        extracted = subject.extract('= @title = "salut"'\
                                    '#content'\
                                    '  .title'\
                                    '    %h1= @title'\
                                    '    = link_to(_("hello world"), :root)')
        extracted.should == ['_("hello world")']
      end

      it 'extracts multiline text with 2 _' do
        extracted = subject.extract('= @title = "salut"'\
                                    '#content'\
                                    '  .title'\
                                    '    %h1= @title'\
                                    '    = link_to(_("hello world"), :root)'\
                                    '    = _("hello")')
        extracted.should == ['_("hello world")', '_("hello")']
      end

      it 'extracts HAML multiline syntax' do
        pending("We don't manage HAML multiline syntax")

        extracted = subject.extract('%div= _(           |'\
                                    '        "hello " + |'\
                                    '        "world"    |'\
                                    '       )           |')
        extracted.should == ['_("hello world")']
      end
    end

    context "exceptions - " do
      it "doesn't extract html text (1)" do
        pending("Text that looks like GetText is also matched for now")

        extracted = subject.extract('gee'\
                                    '  %whiz#idtest.classtest'\
                                    '    Wow this is cool! _("don\'t take it")')
        extracted.should == []
      end

      it "doesn't extract html text (2)" do
        pending("Text that looks like GetText is also matched for now")

        extracted = subject.extract('%div'\
                                    '  \= _("don\'t take it")')
        extracted.should == []
      end

      it "doesn't extract html text (3)" do
        pending("Text that looks like GetText is also matched for now")

        extracted = subject.extract('%div = _("must not be taken !")')
        extracted.should == []
      end
    end

    context "many on same line - " do
      it 'extract 2 _ on the same line' do
        extracted = subject.extract('%div= _("Hi kids !") + _("Hi again kids !")')
        extracted.should == ['_("Hi kids !")', '_("Hi again kids !")']
      end

      it 'extract 2 _ on the same line with single quotes' do
        extracted = subject.extract("%div= _('Hi kids !') + _('Hi again kids !')")
        extracted.should == ["_('Hi kids !')", "_('Hi again kids !')"]
      end

      it 'extract 2 _ on the same line with first one in simple quotes' do
        extracted = subject.extract('%div= _(\'Hi kids !\') + _("Hi again kids !")')
        extracted.should == ['_(\'Hi kids !\')', '_("Hi again kids !")']
      end

      it 'extract 2 _ on the same line with second one in simple quotes' do
        extracted = subject.extract('%div= _("Hi kids !") + _(\'Hi again kids !\')')
        extracted.should == ['_("Hi kids !")', '_(\'Hi again kids !\')']
      end

      it 'extract 2 on the same line without () and with mixed quotes' do
        extracted = subject.extract('%div= _"Hi kids !" + _\'Hi again kids !\'')
        extracted.should == ['_"Hi kids !"', '_\'Hi again kids !\'']
      end

      it 'extract 2 on same line (multiple aguments)' do
        extracted = subject.extract('%div= p_("Eminem", "Hi kids !") + _(\'Hi again kids !\')')
        extracted.should == ['p_("Eminem", "Hi kids !")', '_(\'Hi again kids !\')']
      end
    end

    context "interpolation - " do
      it 'extract interpolated gettext' do
        extracted = subject.extract('%div= "#{_("Hi kids !")}"')
        extracted.should == ['_("Hi kids !")']
      end
    end

    context "weird spaces - " do
      it 'extracts with no space between = and _' do
        extracted = subject.extract('%div=_("Hi kids !")')
        extracted.should == ['_("Hi kids !")']
      end

      it 'extracts with additional space between " and )' do
        extracted = subject.extract('%div=_("Hi kids !" )')
        extracted.should == ['_("Hi kids !" )']
      end

      it 'extracts with spaces after ( and before )' do
        extracted = subject.extract('%div=_(   "Hi kids !" )')
        extracted.should == ['_(   "Hi kids !" )']
      end

      it 'extracts with space between _ and (' do
        extracted = subject.extract('%div=_ ("Hi kids !")')
        extracted.should == ['_ ("Hi kids !")']
      end

      it 'extracts with space between _ and "' do
        extracted = subject.extract('%div=_ "Hi kids !"')
        extracted.should == ['_ "Hi kids !"']
      end

      it 'extracts with no ()' do
        extracted = subject.extract('%div= _"Hi kids !"')
        extracted.should == ['_"Hi kids !"']
      end

      it 'extracts with no () and spaces' do
        extracted = subject.extract('%div= _ "Hi kids !"')
        extracted.should == ['_ "Hi kids !"']
      end

      it 'extracts with HAML parameter' do
        extracted = subject.extract('%div{:alt => _("hello kids")}')
        extracted.should == ['_("hello kids")']
      end

      it 'extracts with new line and -' do
        extracted = subject.extract('%div'\
                                    '  - _("Hi kids !")')
        extracted.should == ['_("Hi kids !")']
      end

      it 'extracts without new line and with -' do
        extracted = subject.extract('%div- _("Hi kids !")')
        extracted.should == ['_("Hi kids !")']
      end
    end
  end
end
