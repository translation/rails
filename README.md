# Gem for [Translation.io](http://translation.io). [ ![Codeship Status](https://app.codeship.com/projects/f7cd4ac0-b73c-0131-51ea-522dcd2196ed/status?branch=master)](https://app.codeship.com/projects/20528) [![Code Climate](https://codeclimate.com/github/aurels/translation-gem/badges/gpa.svg)](https://codeclimate.com/github/aurels/translation-gem) [![Test Coverage](https://codeclimate.com/github/aurels/translation-gem/badges/coverage.svg)](https://codeclimate.com/github/aurels/translation-gem/coverage)

Add this gem to your [Rails](http://rubyonrails.org) application to localize
it using [I18n (YAML)](http://guides.rubyonrails.org/i18n.html) or
[GetText](https://github.com/ruby-gettext/gettext) syntaxes.

Keep it synchronized with your translators on [Translation.io](https://translation.io).

Need help? [contact@translation.io](mailto:contact@translation.io)

## Installation

 1. Add the gem to your project's Gemfile:

```ruby
gem 'translation'
```

 2. Create a new translation project [from the UI](https://translation.io).
 3. Copy the initializer into your Rails app (`config/initializers/translation.rb`)

The initializer looks like this:

```ruby
TranslationIO.configure do |config|
  config.api_key        = 'abcdefghijklmnopqrstuvwxyz012345'
  config.source_locale  = 'en'
  config.target_locales = ['fr', 'nl', 'de', 'es']
end
```

 4. Initialize your translation project with:

    bundle exec rake translation:init

If you later need to add/remove target languages, please read our
[dedicated article](https://translation.io/blog/adding-target-languages) about that.

## Usage

#### I18n (YAML)

```ruby
# Regular
t('inbox.title')

# Plural management
t('inbox.message', count: n)

# Interpolation
t('inbox.hello', name: @user.name)
```

...with the source YAML file:

```yaml
en:
  inbox:
    title:   'text to be translated'
    message:
      zero:  'no messages'
      one:   'one message'
      other: '%{count} messages'
    hello:   'Hello %{name}'
```

You can keep your source YAML file automatically updated using [i18n-tasks](https://github.com/glebm/i18n-tasks).

More information about I18n usage [here](http://guides.rubyonrails.org/i18n.html).

#### GetText

```ruby
# Regular
_("text to be translated")

# Plural management
n_("singular text", "plural text", number)

# Regular with context
p_("context", "text to be translated")

# Plural management with contect
np_("context", "singular text", "plural text", number)

# Interpolations
_('%{city1} is bigger than %{city2}') % { city1: "NYC", city2: "BXL" }
```

More information about GetText usage [here](https://github.com/ruby-gettext/gettext#usage).

## Sync

To send new translatable keys/strings and get new translations from Translation.io, simply run:

    bundle exec rake translation:sync

## Sync and Show Purgeable

If you need to see what are the unused keys/strings from Translation.io, using the current branch as reference:

    bundle exec rake translation:sync_and_show_purgeable

As the name says, this operation will also perform a sync at the same time.

## Sync and Purge

If you need to remove unused keys/strings from Translation.io, using the current branch as reference:

    bundle exec rake translation:sync_and_purge

As the name says, this operation will also perform a sync at the same time.

Warning: all keys that are not present in the current branch will be **permanently deleted from Translation.io**.

## Advanced Configuration Options

The `TranslationIO.configure` block in `config/initializers/translation.rb` can take several optional configuration options.

#### Disable GetText

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

#### Ignored YAML keys

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

#### Source file formats (for GetText)

If you are using GetText and you want to manage other file formats than:

 * `rb`, `erb`, `ruby` and `rabl` for Ruby.
 * `haml` and `mjmlhaml` for [HAML](http://haml.info/).
 * `slim` and `mjmlslim` for [SLIM](http://slim-lang.com/).

Just add them in your configuration file like this:

```ruby
TranslationIO.configure do |config|
  ...
  config.source_formats      << 'rb2'
  config.haml_source_formats << 'haml2'
  config.slim_source_formats << 'slim2'
  ...
end
```

#### Custom localization key prefixes

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

#### Paths where locales are stored (not recommended)

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

## Pure Ruby (without Rails)

This gem was created specifically for Rails, but you can also use it in a pure Ruby project by making some arrangements:

```ruby
  require 'rubygems'
  require 'active_support/all'
  require 'yaml'

  class FakeConfig
    def after_initialize
    end
    def development?
      false
    end
  end

  module Rails
    class Railtie
      def self.rake_tasks
        yield
      end

      def self.initializer(*args)
      end

      def self.config
        ::FakeConfig.new
      end
    end

    def self.env
      ::FakeConfig.new
    end
  end

  task :environment do
  end

  require 'translation'

  I18n.load_path += Dir[File.join('i18n', '**', '*.{yml,yaml}')]

  # Put your configuration here:
  TranslationIO.configure do |config|
    config.yaml_locales_path = 'i18n'
    config.api_key           = ''
    config.source_locale     = 'en'
    config.target_locales    = ['nl', 'de']
    config.metadata_path     = 'i18n/.translation_io'
  end
```

(Thanks [@kubaw](https://github.com/kubaw) for this snippet!)

## Other implementations

These implementations are made by contributors for their own projects and are not
*currently* supported by [Translation.io](https://translation.io). However, they are quite well documented.

Thanks a lot to these contributors for their hard work!

#### React and React-Intl (JavaScript)

* GitHub: https://github.com/deecewan/translation-io
* NPM: https://www.npmjs.com/package/translation-io

Credit: [@deecewan](https://github.com/deecewan)

#### Laravel (PHP)

 * GitHub: https://github.com/armandsar/laravel-translationio
 * Packagist: https://packagist.org/packages/armandsar/laravel-translationio

Credit: [@armandsar](https://github.com/armandsar)

## Credits

The [translation gem](https://rubygems.org/gems/translation) in released under MIT license by [Aurélien Malisart](http://aurelien.malisart.be) and [Michaël Hoste](http://80limit.com) (see MIT-LICENSE
file).

[contact@translation.io](mailto:contact@translation.io)

(c) https://translation.io
