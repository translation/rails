require 'spec_helper'

describe TranslationIO::FlatHash do

  describe '#to_flat_hash' do
    it 'returns a flat hash' do
      hash = {
        'en' => {
          'hello' => 'Hello world',
          'main'  => {
            'menu' => {
              'stuff' => 'This is stuff'
            }
          },
          'bye' => 'Good bye world',

          'bidules' => [
            'bidule 1',
            'bidule 2'
          ],

          'buzzwords' => [
            ['Adaptive', 'Advanced' ],
            ['24 hour', '4th generation']
          ],

          'age' => 42,

          :address => 'Cour du Curé',

          'names' => [
            { 'first' => 'Aurélien', 'last' => 'Malisart' },
            { 'first' => 'Michaël',  'last' => 'Hoste'    }
          ]
        }
      }

      flat_hash = subject.to_flat_hash(hash)

      flat_hash.should == {
        'en.hello'           => 'Hello world'   ,
        'en.main.menu.stuff' => 'This is stuff' ,
        'en.bye'             => 'Good bye world',
        'en.bidules[0]'      => 'bidule 1',
        'en.bidules[1]'      => 'bidule 2',
        'en.buzzwords[0][0]' => 'Adaptive',
        'en.buzzwords[0][1]' => 'Advanced',
        'en.buzzwords[1][0]' => '24 hour',
        'en.buzzwords[1][1]' => '4th generation',
        'en.age'             => 42,
        'en.address'         => 'Cour du Curé',
        'en.names[0].first'  => 'Aurélien',
        'en.names[0].last'   => 'Malisart',
        'en.names[1].first'  => 'Michaël',
        'en.names[1].last'   => 'Hoste'
      }
    end

    it 'returns a flat hash with nil values' do
      hash = {
        "en" => {
          "date" => {
            "formats" => {
              "default" => "%Y-%m-%d",
              "long"    => "%B %d, %Y",
              "short"   =>"%b %d"
            },
            "abbr_day_names"   => [ "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" ],
            "abbr_month_names" => [ nil, "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ],
            "day_names"        => [ "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" ]
          },
          "number" => {
            "format" => {
              "strip_insignificant_zeros" => false
            }
          }
        }
      }

      flat_hash = subject.to_flat_hash(hash)

      flat_hash.should == {
        "en.date.formats.default"                    => "%Y-%m-%d",
        "en.date.formats.long"                       => "%B %d, %Y",
        "en.date.formats.short"                      => "%b %d",
        "en.date.abbr_day_names[0]"                  => "Sun",
        "en.date.abbr_day_names[1]"                  => "Mon",
        "en.date.abbr_day_names[2]"                  => "Tue",
        "en.date.abbr_day_names[3]"                  => "Wed",
        "en.date.abbr_day_names[4]"                  => "Thu",
        "en.date.abbr_day_names[5]"                  => "Fri",
        "en.date.abbr_day_names[6]"                  => "Sat",
        "en.date.abbr_month_names[0]"                => nil,
        "en.date.abbr_month_names[1]"                => "Jan",
        "en.date.abbr_month_names[2]"                => "Feb",
        "en.date.abbr_month_names[3]"                => "Mar",
        "en.date.abbr_month_names[4]"                => "Apr",
        "en.date.abbr_month_names[5]"                => "May",
        "en.date.abbr_month_names[6]"                => "Jun",
        "en.date.abbr_month_names[7]"                => "Jul",
        "en.date.abbr_month_names[8]"                => "Aug",
        "en.date.abbr_month_names[9]"                => "Sep",
        "en.date.abbr_month_names[10]"               => "Oct",
        "en.date.abbr_month_names[11]"               => "Nov",
        "en.date.abbr_month_names[12]"               => "Dec",
        "en.date.day_names[0]"                       => "Sunday",
        "en.date.day_names[1]"                       => "Monday",
        "en.date.day_names[2]"                       => "Tuesday",
        "en.date.day_names[3]"                       => "Wednesday",
        "en.date.day_names[4]"                       => "Thursday",
        "en.date.day_names[5]"                       => "Friday",
        "en.date.day_names[6]"                       => "Saturday",
        "en.number.format.strip_insignificant_zeros" => false
      }

      subject.to_hash(flat_hash).should == hash
    end

    it 'returns another flat hash with nil values at root' do
      hash =  {
        "ja" => nil
      }

      flat_hash = subject.to_flat_hash(hash)

      flat_hash.should == {
        "ja" => nil
      }

      subject.to_hash(flat_hash).should == hash
    end

    it 'returns another flat hash with nil values at sublevel' do
      hash =  {
        "nl" => {
          "hello" => nil
        }
      }

      flat_hash = subject.to_flat_hash(hash)

      flat_hash.should == {
        "nl.hello" => nil
      }

      subject.to_hash(flat_hash).should == hash
    end

    it 'returns another flat hash with nil values in arrays' do
      hash =  {
        "nl" => {
          "date" => {
            "abbr_day_names"   => [ "zon", "maa", "din", "woe", "don", "vri", "zat" ],
            "abbr_month_names" => [ nil, "jan", "feb", "mar", "apr", "mei", "jun", "jul", "aug", "sep", "okt", "nov", "dec" ],
            "day_names"        => [ "zondag", "maandag", "dinsdag", "woensdag", "donderdag", "vrijdag", "zaterdag" ],
            "formats" => {
              "default" => "%d/%m/%Y",
              "long"    => "%e %B %Y",
              "short"   => "%e %b"
            }
          }
        }
      }

      flat_hash = subject.to_flat_hash(hash)

      flat_hash.should == {
        "nl.date.abbr_day_names[0]"    => "zon",
        "nl.date.abbr_day_names[1]"    => "maa",
        "nl.date.abbr_day_names[2]"    => "din",
        "nl.date.abbr_day_names[3]"    => "woe",
        "nl.date.abbr_day_names[4]"    => "don",
        "nl.date.abbr_day_names[5]"    => "vri",
        "nl.date.abbr_day_names[6]"    => "zat",
        "nl.date.abbr_month_names[0]"  => nil,
        "nl.date.abbr_month_names[1]"  => "jan",
        "nl.date.abbr_month_names[2]"  => "feb",
        "nl.date.abbr_month_names[3]"  => "mar",
        "nl.date.abbr_month_names[4]"  => "apr",
        "nl.date.abbr_month_names[5]"  => "mei",
        "nl.date.abbr_month_names[6]"  => "jun",
        "nl.date.abbr_month_names[7]"  => "jul",
        "nl.date.abbr_month_names[8]"  => "aug",
        "nl.date.abbr_month_names[9]"  => "sep",
        "nl.date.abbr_month_names[10]" => "okt",
        "nl.date.abbr_month_names[11]" => "nov",
        "nl.date.abbr_month_names[12]" => "dec",
        "nl.date.day_names[0]"         => "zondag",
        "nl.date.day_names[1]"         => "maandag",
        "nl.date.day_names[2]"         => "dinsdag",
        "nl.date.day_names[3]"         => "woensdag",
        "nl.date.day_names[4]"         => "donderdag",
        "nl.date.day_names[5]"         => "vrijdag",
        "nl.date.day_names[6]"         => "zaterdag",
        "nl.date.formats.default"      => "%d/%m/%Y",
        "nl.date.formats.long"         => "%e %B %Y",
        "nl.date.formats.short"        => "%e %b"
      }

      subject.to_hash(flat_hash).should == hash
    end

    it 'return hash with jokers instead of square brackets' do
      hash = {
        'helpers' => {
          'label' => {
            'startup[attachments_attributes][new_attachments]' => {
              'permissions' => 'Permissions'
            },

            'startup[startup_financing_information_attributes]' => {
              '_transaction' => 'Transaction'
            }
          }
        }
      }

      flat_hash = subject.to_flat_hash(hash)

      flat_hash.should == {
        'helpers.label.startup<@~<attachments_attributes>@~><@~<new_attachments>@~>.permissions' => 'Permissions',
        'helpers.label.startup<@~<startup_financing_information_attributes>@~>._transaction'     => 'Transaction'
      }

      subject.to_hash(flat_hash).should == {
        'helpers' => {
          'label' => {
            'startup[attachments_attributes][new_attachments]' => {
              'permissions' => 'Permissions'
            },

            'startup[startup_financing_information_attributes]' => {
              '_transaction' => 'Transaction'
            }
          }
        }
      }
    end
  end

  describe '#to_hash' do
    it 'returns a simple hash' do
      flat_hash = {
        'en' => 'hello'
      }

      hash = subject.to_hash(flat_hash)

      hash.should == { 'en' => 'hello' }
    end

    it 'returns a simple array' do
      flat_hash = {
        'en[0]' => 'hello'
      }

      hash = subject.to_hash(flat_hash)

      hash.should == { 'en' => ['hello'] }
    end

    it 'returns a simple array with 2 elements' do
      flat_hash = {
        'en[0]' => 'hello',
        'en[1]' => 'world'
      }

      hash = subject.to_hash(flat_hash)

      hash.should == { 'en' => ['hello', 'world'] }
    end


    it 'returns a double array' do
      flat_hash = {
        'en[0][0]' => 'hello',
        'en[0][1]' => 'world'
      }

      hash = subject.to_hash(flat_hash)

      hash.should == { 'en' => [['hello', 'world']] }
    end

    it 'returns a double array with hash in it' do
      flat_hash = {
        'en[0][0].hello'    => 'hello world',
        'en[0][1].goodbye'  => 'goodbye world',
        'en[1][0].hello2'   => 'hello lord',
        'en[1][1].goodbye2' => 'goodbye lord'
      }

      hash = subject.to_hash(flat_hash)

      hash.should == {
        'en' => [
          [
            { 'hello'   => 'hello world'   },
            { 'goodbye' => 'goodbye world' }
          ],
          [
            { 'hello2'   => 'hello lord'   },
            { 'goodbye2' => 'goodbye lord' }
          ]
        ]
      }
    end

    it 'return a hash with arrays at many places' do
      flat_hash = {
        'fr[0][0].bouh.salut[0]'  => 'blabla',
        'fr[0][0].bouh.salut[1]'  => 'blibli',
        'fr[1][0].salut'          => 'hahah',
        'fr[1][1].ha'             => 'house'
      }

      hash = subject.to_hash(flat_hash)

      hash.should == {
        'fr' => [
          [{
            'bouh' => {
              'salut' => [ 'blabla', 'blibli' ]
            }
          }],
          [
            { 'salut' => 'hahah' },
            { 'ha'    => 'house'}
          ]
        ]
      }
    end

    it 'returns a hash' do
      flat_hash = {
        'en.hello'              => 'Hello world'   ,
        'en.main.menu[0].stuff' => 'This is stuff' ,
        'en.bye'                => 'Good bye world',
        'en.bidules[0]'         => 'bidule 1',
        'en.bidules[1]'         => 'bidule 2',
        'en.family[0][0]'       => 'Ta mère',
        'en.family[0][1]'       => 'Ta soeur',
        'en.family[1][0]'       => 'Ton père',
        'en.family[1][1]'       => 'Ton frère'
      }

      hash = subject.to_hash(flat_hash)

      hash.should == {
        'en' => {
          'hello' => 'Hello world',
          'main'  => {
            'menu' => [
              'stuff' => 'This is stuff'
            ]
          },
          'bye' => 'Good bye world',

          'bidules' => [
            'bidule 1',
            'bidule 2'
          ],

          'family' => [
            ['Ta mère', 'Ta soeur'],
            ['Ton père', 'Ton frère'],
          ]
        }
      }
    end
  end

  it 'returns a hash with missing array values' do
    flat_hash = {
      "nl.date.abbr_month_names[1]"  => "jan",
      "nl.date.abbr_month_names[2]"  => "feb",
      "nl.date.abbr_month_names[3]"  => "mar"
    }

    hash = subject.to_hash(flat_hash)

    hash.should == {
      'nl' => {
        'date' => {
          'abbr_month_names' => [nil, 'jan', 'feb', 'mar']
        }
      }
    }
  end

  it 'returns a hash when inconsistencies in YAML (can be caused by YamlLocalizationFillService)' do
    flat_hash = {
      "en.date.order"    => "%d.%m.%Y",
      "en.date.order[0]" => :year,
      "en.date.order[1]" => :month,
      "en.date.order[2]" => :day,
    }

    hash = subject.to_hash(flat_hash)

    hash.should == {
      'en' => {
        'date' => {
          'order' => "%d.%m.%Y"
        }
      }
    }
  end

  it 'returns a hash when inconsistencies in YAML (can be caused by YamlLocalizationFillService) - 2' do
    flat_hash = {
      "en.date.order[0]" => :year,
      "en.date.order[1]" => :month,
      "en.date.order[2]" => :day,
      "en.date.order"    => "%d.%m.%Y",
    }

    hash = subject.to_hash(flat_hash)

    hash.should == {
      'en' => {
        'date' => {
          'order' => "%d.%m.%Y"
        }
      }
    }
  end

  it 'handles empty/nil keys' do
    flat_hash = {
      ""  => "jan"
    }

    hash = subject.to_hash(flat_hash)

    hash.should == {
      nil => "jan"
    }
  end

  it 'handles nil values' do
    flat_hash = {
      "key"  => nil
    }

    hash = subject.to_hash(flat_hash)

    hash.should == {
      "key" => nil
    }
  end

  it 'handles nil values with sublevel' do
    flat_hash = {
      "key.test"  => nil
    }

    hash = subject.to_hash(flat_hash)

    hash.should == {
      "key" => {
        "test" => nil
      }
    }
  end

  it 'handles joker square brackets in hash keys' do
    flat_hash = {
      'helpers.label.startup<@~<attachments_attributes>@~><@~<new_attachments>@~>.permissions' => 'Permissions',
      'helpers.label.startup<@~<startup_financing_information_attributes>@~>._transaction'     => 'Transaction'
    }

    hash = subject.to_hash(flat_hash)

    hash.should == {
      'helpers' => {
        'label' => {
          'startup[attachments_attributes][new_attachments]' => {
            'permissions' => 'Permissions'
          },

          'startup[startup_financing_information_attributes]' => {
            '_transaction' => 'Transaction'
          }
        }
      }
    }
  end

  it 'handles joker square brackets and normal brackets (arrays) in hash keys' do
    flat_hash = {
      'helpers[0].startup<@~<first_key>@~>[0]' => 'blabla1',
      'helpers[0].startup<@~<first_key>@~>[1]' => 'blabla2',
      'helpers[1].startup<@~<second_key>@~>[0]' => 'blibli1',
      'helpers[1].startup<@~<second_key>@~>[1]' => 'blibli2',
      'helpers[2].startup<@~<third_key>@~>.key' => 'bloblo',
    }

    hash = subject.to_hash(flat_hash)

    hash.should == {
      'helpers' => [
        { 'startup[first_key]'  => [ 'blabla1', 'blabla2' ] },
        { 'startup[second_key]' => [ 'blibli1', 'blibli2' ] },
        { 'startup[third_key]'  => {
          'key' => 'bloblo'
        }}
      ]
    }

    subject.to_flat_hash(hash).should == flat_hash
  end

  it 'handles inconsistant values in hashs' do
    flat_hash = {
      "errors.messages.too_long"       => "est trop long (pas plus de %{count} caractères)",
      "errors.messages.too_long.one"   => "est trop long (pas plus d'un caractère)",
      "errors.messages.too_long.other" => "est trop long (pas plus de %{count} caractères)"
    }

    hash = subject.to_hash(flat_hash)

    hash.should == {
      "errors" => {
        "messages" => {
          "too_long" => "est trop long (pas plus de %{count} caractères)"
        }
      }
    }
  end

  it 'handles inconsistant values in hashs - 2' do
    flat_hash = {
      "menus[0].a" => "Menu A",
      "menus.b"    => "Menu B",
      "menus.c"    => "Menu C",
      "menus[0].b" => "Menu B2",
      "menus[1]"   => "Menu D"
    }

    hash = subject.to_hash(flat_hash)

    hash.should == {
      "menus" => [{
          "a" => "Menu A",
          "b" => "Menu B2",
        },
        "Menu D"
      ]
    }
  end

  it 'handles inconsistant values in hashs - 3' do
    flat_hash = {
      "menus.a"      => "Menu A",
      "menus.a.test" => "test"
    }

    hash = subject.to_hash(flat_hash)

    hash.should == {
      "menus" => {
        "a" => "Menu A",
      }
    }
  end

  it 'handles inconsistant values in hashs - 4' do
    flat_hash = {
      "title.edit" => "Modifier",
      "title.new"  => "Nouveau",
      "title"      => ""
    }

    hash = subject.to_hash(flat_hash)

    hash.should == {
      "title" => "",
    }
  end

  it 'handles inconsistant values in hashs - 5' do
    flat_hash = {
      "services.renting.description"              => 'Renting is great!',
      "services.renting.description.price.header" => 'What is the price?',
    }

    hash = subject.to_hash(flat_hash)

    hash.should == {
      'services' => {
        'renting' => {
          'description' => "Renting is great!"
        }
      }
    }
  end

  it "handles inconsistant values in hash - 6", :focus => true do
    flat_hash = {
      "services.renting.description"                   => 'Renting is great!',
      "services.renting.description.price.header.test" => 'What is the price?',
    }

    hash = subject.to_hash(flat_hash)

    hash.should == {
      'services' => {
        'renting' => {
          'description' => "Renting is great!"
        }
      }
    }
  end

  it "handles inconsistant values in hash - 7" do
    flat_hash = {
      "services.renting.description.price.header.test" => 'What is the price?',
      "services.renting.description"                   => 'Renting is great!',
    }

    hash = subject.to_hash(flat_hash)

    hash.should == {
      'services' => {
        'renting' => {
          'description' => "Renting is great!"
        }
      }
    }
  end
end
