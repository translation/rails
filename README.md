# [Translation.io](https://translation.io) client for Ruby on Rails

[![Software License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](LICENSE.md)
[![Build Status](https://img.shields.io/travis/translation/rails/master.svg?style=flat-square)](https://travis-ci.org/translation/rails)
[![Test Coverage](https://codeclimate.com/github/translation/rails/badges/coverage.svg)](https://codeclimate.com/github/translation/rails/coverage)
[![Gem Version](https://badge.fury.io/rb/translation.svg)](https://badge.fury.io/rb/translation)
[![Downloads](https://img.shields.io/gem/dt/translation.svg)](https://rubygems.org/gems/translation)

Add this gem to localize your Ruby on Rails application.

Use the official Rails syntax (with [YAML](#i18n-yaml) files) or use the [GetText](#gettext) syntax.

Write only the source text, and keep it synchronized with your translators on [Translation.io](https://translation.io).

<a href="https://translation.io">
  <img width="720px" alt="Translation.io interface" src="https://translation.io/gifs/translation.gif">
</a>

[Technical Demo](https://translation.io/videos/rails.mp4) (2.5min)

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
 * [Manage Languages](#manage-languages)
   * [Add or Remove Language](#add-or-remove-language)
   * [Edit Language](#edit-language)
   * [Custom Languages](#custom-languages)
 * [Change the current locale](#change-the-current-locale)
   * [Globally](#globally)
   * [Locally](#locally)
 * [Continuous Integration](#continuous-integration)
 * [Advanced Configuration Options](#advanced-configuration-options)
   * [Disable GetText](#disable-gettext)
   * [Ignored YAML keys](#ignored-yaml-keys)
   * [Source file formats (for GetText)](#source-file-formats-for-gettext)
   * [Custom localization key prefixes](#custom-localization-key-prefixes)
   * [Paths where locales are stored (not recommended)](#paths-where-locales-are-stored-not-recommended)
 * [Pure Ruby (without Rails)](#pure-ruby-without-rails)
 * [Testing](#testing)
 * [Contributing](#contributing)
 * [List of clients for Translation.io](#list-of-clients-for-translationio)
   * [Ruby on Rails (Ruby)](#ruby-on-rails-ruby)
   * [Laravel (PHP)](#laravel-php)
   * [React and React-Intl (JavaScript)](#react-and-react-intl-javascript)
   * [Others](#others)
 * [License](#license)

## Translation syntaxes

### I18n (YAML)

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

### GetText

This gem adds the GetText support to Rails. We [strongly suggest](https://translation.io/blog/gettext-is-better-than-rails-i18n)
that you use GetText to translate your application since it allows an easier and more complete syntax.

Also, you won't need to create and manage any YAML file since your code will be
automatically scanned for any string to translate.

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

### Sync

To send new translatable keys/strings and get new translations from Translation.io, simply run:

```bash
$ bundle exec rake translation:sync
```

### Sync and Show Purgeable

If you need to find out what are the unused keys/strings from Translation.io, using the current branch as reference:

```bash
$ bundle exec rake translation:sync_and_show_purgeable
```

As the name says, this operation will also perform a sync at the same time.

### Sync and Purge

If you need to remove unused keys/strings from Translation.io, using the current branch as reference:

```bash
$ bundle exec rake translation:sync_and_purge
```

As the name says, this operation will also perform a sync at the same time.

Warning: all keys that are not present in the current branch will be **permanently deleted from Translation.io**.

## Manage Languages

### Add or Remove Language

You can add or remove a language by updating `config.target_locales = []` in your
`config/initializers/translation.rb` file, and executing `rake translation:sync`.

If you want to add a new language with existing translations (ex. if you already have
a translated YAML file in your project), you will need to create a new project on
Translation.io and run `rake translation:init` for them to appear.

### Edit Language

To edit existing languages while keeping their translations (e.g. changing from `en` to `en-US`).

 1. Create a new project on Translation.io with the correct languages.
 2. Adapt `config/initializers/translation.rb` (new API key and languages)
 3. Adapt language names and root keys of the YAML files in your project (optional: adapt GetText directories and `.po` headers)
 4. Execute `rake translation:init` and check that everything went fine.
 5. Invite your collaborators in the new project.
 6. Remove the old project.

Since you created a new project, the translation history and tags will unfortunately be lost.

### Custom Languages

You may want to add a custom language that is derived from an existing language.
It's useful if you want to change some translations for another instance of the
application or for a specific customer.

The structure of a custom language is : existing language code + "-" + custom text.

Examples: `en-microsoft` or `fr-BE-custom`.

Custom languages can be added like any other language and fallbacks work as expected.
It means that if the `en-microsoft.some_key` is missing, then it will fallback to
`en.some_key`. So you only need to translate keys that should be customized.

Note that fallback are chained, so `fr-be-custom` will fallback to `fr-be` that will
itself fallback to `fr`.

Using GetText syntax, it will only fallback to the source language. So either you
create a fallback mechanism by yourself or you avoid fallbacking
by translating everything in Translation.io for that custom language.

## Change the current locale

### Globally

The easiest way to change the current locale is with `set_locale`.

```ruby
class ApplicationController < ActionController::Base
  before_action :set_locale

  [...]
end
```

It will automatically set the locale extracted from the user's browser `HTTP_ACCEPT_LANGUAGE` value, and keep it in the session between requests.

Update the current locale by redirecting the user to https://yourdomain.com?locale=fr or even https://yourdomain.com/fr if you scoped your routes like this:

```ruby
scope "/:locale", :constraints => { locale: /[a-z]{2}/ } do
  resources :pages
end
```

The `set_locale` code is [here](https://github.com/translation/rails/blob/master/lib/translation_io/controller.rb#L3), feel free to override it with your own locale management.

Don't forget to define your available locales with [I18n.available_locales](http://guides.rubyonrails.org/i18n.html#setup-the-rails-application-for-internationalization).

More examples here: https://translation.io/blog/set-current-locale-in-your-rails-app

### Locally

This command will change the locale for both [I18n (YAML)](#i18n-yaml) and [GetText](#gettext):

```ruby
I18n.locale = 'fr'
```

You can call it several times in the same page if you want to switch between languages.

More examples here: https://translation.io/blog/rails-i18n-with-locale

## Continuous Integration

If you want fresh translations in your Continuous Integration workflow, you may find yourself calling `bundle exec rake translation:sync` very frequently. 

Since this task can't be concurrently executed (we have a [mutex](https://en.wikipedia.org/wiki/Mutual_exclusion) strategy with a queue but it returns an error under heavy load), we implemented this threadsafe readonly task: 

```bash
$ bundle exec rake translation:sync_readonly
```

This task will prevent your CI to fail and still provide new translations. But be aware that it won't send new keys from your code to Translation.io so you still need to call `bundle exec rake translation:sync` at some point during development.

## Advanced Configuration Options

The `TranslationIO.configure` block in `config/initializers/translation.rb` can take several optional configuration options.

Some options are described below but for an exhaustive list, please refer to [config.rb](https://github.com/translation/rails/blob/master/lib/translation_io/config.rb).

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

### Source file formats (for GetText)

If you are using GetText and you want to manage other file formats than:

 * `rb`, `ruby` and `rabl` for Ruby.
 * `erb` and `inky` for Ruby templating.
 * `haml` and `mjmlhaml` for [HAML](http://haml.info/).
 * `slim` and `mjmlslim` for [SLIM](http://slim-lang.com/).

Just add them in your configuration file like this:

```ruby
TranslationIO.configure do |config|
  ...
  config.source_formats      << 'rb2'
  config.erb_source_formats  << 'erb2'
  config.haml_source_formats << 'haml2'
  config.slim_source_formats << 'slim2'
  ...
end
```

### Custom localization key prefixes

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

## Testing

To run the specs:

```bash
$ bundle exec rspec
```

## Contributing

Please read the [CONTRIBUTING](CONTRIBUTING.md) file.

## List of clients for Translation.io

These implementations were usually started by contributors for their own projects.
Some of them are officially supported by [Translation.io](https://translation.io)
and some are not yet supported. However, they are quite well documented.

Thanks a lot to these contributors for their hard work!

### Ruby on Rails (Ruby)

Officially Supported on [https://translation.io/rails](https://translation.io/rails)

 * GitHub: https://github.com/translation/rails
 * RubyGems: https://rubygems.org/gems/translation/

Credits: [@aurels](https://github.com/aurels), [@michaelhoste](https://github.com/michaelhoste)

### Laravel (PHP)

Officially Supported on [https://translation.io/laravel](https://translation.io/laravel)

 * GitHub: https://github.com/translation/laravel
 * Packagist: https://packagist.org/packages/tio/laravel

Credits: [@armandsar](https://github.com/armandsar), [@michaelhoste](https://github.com/michaelhoste)

### React and React-Intl (JavaScript)

 * GitHub: https://github.com/deecewan/translation-io
 * NPM: https://www.npmjs.com/package/translation-io

Credits: [@deecewan](https://github.com/deecewan)

### Others

If you want to create a new client for your favorite language or framework, feel
free to reach us on [contact@translation.io](mailto:contact@translation.io) and
we'll assist you with the workflow logic and send you API docs.

## License

The [translation gem](https://rubygems.org/gems/translation) in released under MIT license by
[Aurélien Malisart](http://aurelien.malisart.be) and [Michaël Hoste](https://80limit.com) (see [LICENSE](LICENSE) file).

(c) [https://translation.io](https://translation.io) / [contact@translation.io](mailto:contact@translation.io)
