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
end
