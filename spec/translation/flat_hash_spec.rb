require 'spec_helper'

describe Translation::FlatHash do


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
      }
    end
  end

  describe '#to_hash' do
    it 'returns a hash' do
      flat_hash = {
        'en.hello'           => 'Hello world'   ,
        'en.main.menu.stuff' => 'This is stuff' ,
        'en.bye'             => 'Good bye world',
        'en.bidules[0]'      => 'bidule 1',
        'en.bidules[1]'      => 'bidule 2',
      }

      hash = subject.to_hash(flat_hash)

      hash.should == {
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
          ]
        }
      }
    end
  end
end
