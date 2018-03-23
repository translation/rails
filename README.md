# [Translation.io](https://translation.io) client for Ruby on Rails

[![Software License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](LICENSE.md)
[![Codeship Status](https://app.codeship.com/projects/f7cd4ac0-b73c-0131-51ea-522dcd2196ed/status?branch=master)](https://app.codeship.com/projects/20528)
[![Test Coverage](https://codeclimate.com/github/aurels/translation-gem/badges/coverage.svg)](https://codeclimate.com/github/aurels/translation-gem/coverage)

Add this gem to translate your application with [I18n (YAML)](#i18n-yaml) or
[GetText](#gettext) syntaxes.

Keep it synchronized with your translators on [Translation.io](https://translation.io).

[![Image](https://translation.io/interface.png)](https://translation.io)

Need help? [contact@translation.io](mailto:contact@translation.io)

Table of contents
=================

 * [Translation syntaxes](#translation-syntaxes)
   * [I18n (YAML)](#i18n-yaml)
   * [GetText](#gettext)
 * [Installation](#installation)
 * [Usage](#usage)
   * [Sync](#sync)
   * [Sync and Show Purgeable](#sync-and-show-purgeable)
   * [Sync and Purge](#sync-and-purge)
 * [Advanced Configuration Options](#advanced-configuration-options)
   * [Disable GetText](#disable-gettext)
   * [Ignored YAML keys](#ignored-yaml-keys)
   * [Source file formats (for GetText)](#source-file-formats-for-gettext)
   * [Custom localization key prefixes](#custom-localization-key-prefixes)
   * [Paths where locales are stored (not recommended)](#paths-where-locales-are-stored-not-recommended)
 * [Pure Ruby (without Rails)](#pure-ruby-without-rails)
 * [List of clients for Translation.io](#list-of-clients-for-translationio)
   * [Ruby on Rails (Ruby)](#ruby-on-rails-ruby)
   * [Laravel (PHP)](#laravel-php)
   * [React and React-Intl (JavaScript)](#react-and-react-intl-javascript)
 * [Testing](#testing)
 * [Contributing](#contributing)
 * [Credits](#credits)

## Translation syntaxes

#### I18n (YAML)

The default [Rails Internationalization API](http://guides.rubyonrails.org/i18n.html).

```ruby
# Regular
t('inbox.title')

# Pluralization
t('inbox.message', count: n)

# Interpolation
t('inbox.hello', name: @user.name)
```

With the source YAML file:

```yaml
en:
  inbox:
    title:   'Title to be translated'
    message:
      zero:  'no messages'
      one:   'one message'
      other: '%{count} messages'
    hello:   'Hello %{name}'
```

You can keep your source YAML file automatically updated using [i18n-tasks](https://github.com/glebm/i18n-tasks).

#### GetText

This gem adds the GetText support to Rails. We [strongly suggest](https://translation.io/blog/gettext-is-better-than-rails-i18n)
that you use GetText to translate your applications since it allows a simpler and more maintainable syntax.

```ruby
# Regular
_("Text to be translated")

# Pluralization
n_("Singular text", "Plural text", number)

# Regular with context
p_("context", "Text to be translated")

# Pluralization with context
np_("context", "Singular text", "Plural text", number)

# Interpolations
_('%{city1} is bigger than %{city2}') % { city1: "NYC", city2: "BXL" }
```

You don't need another file with source text or translations, everything will
be synchronized from Translation.io, and stored on PO/MO files.

More information about GetText syntax [here](https://github.com/ruby-gettext/gettext#usage).

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

 4. Initialize your project and push existing translations to Translation.io with:

```bash
$ bundle exec rake translation:init
```

If you later need to add/remove target languages, please read our
[documentation](https://translation.io/blog/adding-target-languages) about that.

## Usage

#### Sync

To send new translatable keys/strings and get new translations from Translation.io, simply run:

```bash
$ bundle exec rake translation:sync
```

#### Sync and Show Purgeable

If you need to find out what are the unused keys/strings from Translation.io, using the current branch as reference:

```bash
$ bundle exec rake translation:sync_and_show_purgeable
```

As the name says, this operation will also perform a sync at the same time.

#### Sync and Purge

If you need to remove unused keys/strings from Translation.io, using the current branch as reference:

```bash
$ bundle exec rake translation:sync_and_purge
```

As the name says, this operation will also perform a sync at the same time.

Warning: all keys that are not present in the current branch will be **permanently deleted from Translation.io**.

## Advanced Configuration Options

The `TranslationIO.configure` block in `config/initializers/translation.rb` can take several optional configuration options.

Some options are described below but for an exhaustive list, please refer to [config.rb](https://github.com/aurels/translation-gem/blob/master/lib/translation_io/config.rb).

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
numbers to be displayed, right? Moreover, this special keys often contain special constructions (e.g.,
with percent signs or spaces) that he might break.

We think localization is part of the configuration of the app and it should not reach the translator UI at all.
That's why these localization keys are detected and separated on a dedicated YAML file with Translation.io.

We automatically treat [known localization keys](lib/translation_io/yaml_entry.rb), but if you would like
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

## List of clients for Translation.io

These implementations were usually started by contributors for their own projects.
Some of them are officially supported by [Translation.io](https://translation.io)
and some are not yet supported. However, they are quite well documented.

Thanks a lot to these contributors for their hard work!

If you want to create a new client for your favorite language or framework, feel
free to reach us on [contact@translation.io](mailto:contact@translation.io) and
we'll assist you with the workflow logic and send you API docs.

#### Ruby on Rails (Ruby)

Officially Supported on [https://translation.io/rails](https://translation.io/rails)

 * GitHub: https://github.com/aurels/translation-gem
 * RubyGems: https://rubygems.org/gems/translation/

Credits: [@aurels](https://github.com/aurels), [@michaelhoste](https://github.com/michaelhoste)

#### Laravel (PHP)

Officially Supported on [https://translation.io/laravel](https://translation.io/laravel)

 * GitHub: https://github.com/translation/laravel
 * Packagist: https://packagist.org/packages/tio/laravel

Credits: [@armandsar](https://github.com/armandsar), [@michaelhoste](https://github.com/michaelhoste)

#### React and React-Intl (JavaScript)

 * GitHub: https://github.com/deecewan/translation-io
 * NPM: https://www.npmjs.com/package/translation-io

Credits: [@deecewan](https://github.com/deecewan)

## Testing

To run the specs:

```bash
$ bundle exec rspec
```

## Contributing

Please read the [CONTRIBUTING](CONTRIBUTING.md) file.

## Credits

The [translation gem](https://rubygems.org/gems/translation) in released under MIT license by
[Aurélien Malisart](http://aurelien.malisart.be) and [Michaël Hoste](https://80limit.com) (see [LICENSE](LICENSE) file).

(c) [https://translation.io](https://translation.io) / [contact@translation.io](mailto:contact@translation.io)
