# Ruby/Rails gem for [Translation.io](http://translation.io).

![Build Status](https://www.codeship.io/projects/f7cd4ac0-b73c-0131-51ea-522dcd2196ed/status)

## Description

Add this gem to your [Rails](http://rubyonrails.org) app to translate it with [Translation.io](http://translation.io).

## Installation

Add the gem to your project's Gemfile:

```ruby
gem 'translation'
```

Then:

* Create a translation project [from the UI](https://translation.io).
* Copy the initializer into your Rails app (`config/initializers/translation.rb`)

The initializer looks like this:

```ruby
TranslationIO.configure do |config|
  config.api_key        = 'some api key which is very long'
  config.source_locale  = 'en'
  config.target_locales = ['fr', 'nl', 'de', 'es']
end
```

And finish by inititalizing your translation project with:

    bundle exec rake translation:init

If you later need to add/remove target languages, please read our
[dedicated article](https://translation.io/blog/adding-target-languages) about that.

## Sync

To send new translatable keys/strings and get new translations from Translation.io, simply run:

    bundle exec rake translation:sync

## Sync and Purge

If you also need to remove unused keys/strings from Translation.io using the current branch as reference:

    bundle exec rake translation:sync_and_purge

As the name says, this operation will also perform a sync at the same time.

Warning: all keys that are not present in the current branch will be **permanently deleted both on Translation.io and in your app**.

## Advanced Configuration Options

The `TranslationIO.configure` block in `config/initializers/translation.rb` can take several optional configuration options.

### Disable GetText

Sometimes, you only want to use YAML and don't want to be bothered by GetText at all.
For these cases, you just have to add `disable_gettext` in the config file.

For example:

```ruby
TranslationIO.configure do |config|
  ...
  config.disable_gettext = true
  ...
end
```

### Ignored YAML keys

Sometimes you would like to ignore some YAML keys coming from gems or so.
You can use the `ignored_key_prefixes` for that.

For example:

```ruby
TranslationIO.configure do |config|
  ...
  config.ignored_key_prefixes = [
    'number.human.',
    'admin.',
    'errors.messages.',
    'activerecord.errors.messages.',
    'will_paginate.',
    'helpers.page_entries_info.',
    'views.pagination.',
    'enumerize.visibility.'
  ]
  ...
end
```

### Custom localization key prefixes

Rails YAML files contain not only translation strings but also localization values (integers, arrays, booleans)
in the same place and that's bad. For example: date formats, number separators, default
currency or measure units, etc.

A translator is supposed to translate, not localize. That's not his role to choose how you want your dates or
numbers to be displayed, right ? Moreover, this special keys often contain special constructions (e.g.,
with percent signs or spaces) that he might break.

We think localization is part of the configuration of the app and it should not reach the translator UI at all.
That's why these localization keys are detected and separated on a dedicated YAML file with Translation.io.

We automatically threat [known localization keys](lib/translation_io/yaml_entry.rb), but if you would like
to add some more, use the `localization_key_prefixes` option.

For example:

```ruby
TranslationIO.configure do |config|
  ...
  config.localization_key_prefixes = ['my_gem.date.formats']
  ...
end
```

### Paths where locales are stored (not recommended)

You can specify where your GetText and YAML files are on disk:

```ruby
TranslationIO.configure do |config|
  ...
  config.locales_path      = 'some/path' # defaults to config/locales/gettext
  config.yaml_locales_path = 'some/path' # defaults to config/locales
  ...
end
```

## Tests

To run the specs:

    bundle exec rspec

## Credits

The [translation gem](https://rubygems.org/gems/translation) in released under MIT license by [Aurélien Malisart](http://aurelien.malisart.be) and [Michaël Hoste](http://80limit.com) (see MIT-LICENSE
file).

(c) http://translation.io
