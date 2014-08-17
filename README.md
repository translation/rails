# Ruby/Rails gem for [Translation.io](http://translation.io).

## Description

Add this gem to your [Rails](http://rubyonrails.org) app to translate it with [Translation.io](http://translation.io).

## Installation

Add the gem to your project's Gemfile :

    gem 'translation'

Then :

* Create a translation project from the UI.
* Copy the initializer into your Rails app (`config/initializers/translation.rb`)

And finish by inititalizing your translation project with :

    bundle exec rake translation:init

## Synchronization

To get new translations from Translation.io and to send new translatable strings, simply run :

    bundle exec rake translation:sync

## Purge

If you need to remove unused keys taking the current branch as reference :

    bundle exec rake translation:purge

Note that this operation will also perform a sync at the same time.

Warning : all keys that are not present in the current branch will be **permanently deleted both on Translation.io and in your app**.

## Tests

To run the specs :

    bundle
    bundle exec rspec

## Credits

The [translation gem](https://rubygems.org/gems/translation) in released under MIT license by [Aurélien Malisart](http://aurelien.malisart.be) and [Michaël Hoste](http://80limit.com) (see MIT-LICENSE
file).

(c) http://translation.io
