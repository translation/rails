#  Changelog

## [v1.17](https://github.com/translation/rails/releases/tag/v1.17) (2018-11-12)

#### New features:

 * New 'rake translation:sync_readonly' task for concurrent syncing (CI). See README.
 * Increase timeout for HTTP requests.

## [v1.16](https://github.com/translation/rails/releases/tag/v1.16) (2018-10-10)

#### New features:

 * Make the parsing compatible with .inky extension files (like erb templating) + add custom "erb-like" extensions in configuration.

## [v1.15](https://github.com/translation/rails/releases/tag/v1.15) (2018-09-27)

#### Fixes (bugs & defects):

 * Debug error and more specs for inconsistent YAML.

## [v1.14](https://github.com/translation/rails/releases/tag/v1.14) (2018-03-23)

#### New features:

 * Add params to each request to specify the version and the client (`gem_version` become `version` and `client` is always `rails`). Needed because now there are also Laravel projects on Translation.io (cf. https://github.com/translation/laravel).

## [v1.13](https://github.com/translation/rails/releases/tag/v1.13) (2018-02-19)

#### New features:

 * `rake translation:sync_and_show_purgeable` specifies the languages of the to-be-removed segments (because sometimes it will only delete a segment related to a removed language).

## [v1.12](https://github.com/translation/rails/releases/tag/v1.12) (2018-02-06)

#### Fixes (bugs & defects):

 * Exit with failure status code as opposed to implicit success in rescue blocks ([#22](https://github.com/translation/rails/pull/22)). Thanks @Dombo!

## [v1.11](https://github.com/translation/rails/releases/tag/v1.11) (2017-12-14)

#### Fixes (bugs & defects):

 * Update GetText dependency to >= 3.2.5 because of [That issue that evaluate strings of whole code](https://github.com/ruby-gettext/gettext/issues/56)
 * Call `send(:include)` to make it compatible with Ruby < 2.1

## [v1.10](https://github.com/translation/rails/releases/tag/v1.10) (2017-10-18)

#### New features:

 * Add `rake translation:sync_and_show_purgeable` task to see all unused keys/strings from Translation.io, using the current branch as reference ([#20](https://github.com/translation/rails/issues/20)).
 * Better file formats configuration in configuration file ([#14](https://github.com/translation/rails/pull/14)).
 * Better wording

#### Fixes (bugs & defects):

 * Debug error and more specs for inconsistent YAML.

## [v1.9](https://github.com/translation/rails/releases/tag/v1.9) (2017-02-16)

#### New features:

 * Messages with project URL on init/sync.
 * Check if no git conflicts in .translation_io hidden file.
 * Check syntax of generated ruby files for HAML/SLIM parsing.

## [v1.8.4](https://github.com/translation/rails/releases/tag/v1.8.4) (2016-12-02)

#### Fixes (bugs & defects):

 * Debug FlatHash.to_hash in a very specific case. This issue should not happen in consistent YAML files.

## [v1.8.3](https://github.com/translation/rails/releases/tag/v1.8.3) (2016-09-06)

#### Fixes (bugs & defects):

 * Don't set LC_TYPE to avoid warnings on Linux ([#7](https://github.com/translation/rails/pull/7))

## [v1.8.2](https://github.com/translation/rails/releases/tag/v1.8.2) (2016-07-20)

#### Fixes (bugs & defects):

 * Add missing wee and wen locales to Locale (Upper Sorbian and Lower Sorbian)

## [v1.8.1](https://github.com/translation/rails/releases/tag/v1.8.1) (2016-07-08)

#### Fixes (bugs & defects):

 * Removed clutter (lost puts)

## [v1.8](https://github.com/translation/rails/releases/tag/v1.8) (2016-07-06)

#### New features:

 * When `disable_gettext` is set to `true`, only load GetText libraries where needed to consume less memory.

## [v1.7](https://github.com/translation/rails/releases/tag/v1.7) (2016-04-19)

#### New features:

 * Force use of Gettext 3.2.2 because of bad Chinese (traditional/simplified) language management for previous versions of Gettext: [ruby-gettext/gettext#45](https://github.com/ruby-gettext/gettext/pull/45)

## [v1.6](https://github.com/translation/rails/releases/tag/v1.6) (2016-02-03)

#### Fixes (bugs & defects):

 * Debug check of source locale during init.

## [v1.5](https://github.com/translation/rails/releases/tag/v1.5) (2016-01-08)

#### New features:

 * Warning when source YAML text was changed in local project and in Translation.io.
 * Better warning messages for source and target locale consistencies during init.

## [v1.4](https://github.com/translation/rails/releases/tag/v1.4) (2015-12-11)

#### New features:

 * New configuration option : `disable_gettext` (gettext folder will not appear, and code will not be parsed for Gettext keys)
 * Better HAML and SLIM management for situations where `_` is used without parenthesis.

## [v1.3](https://github.com/translation/rails/releases/tag/v1.3) (2015-11-13)

#### New features:

 * Description text on top of localization files (YML).
 * New error message if languages of project and languages of configuration don't match.
 * New config option `config.ignored_source_files` to ignore some files for gettext parsing.

#### Fixes (bugs & defects):

 * Rescue Gettext parsing errors when this case happens `_ | %w()`. It will not fail and will raise a error message with the line of the issue.

## [v1.2](https://github.com/translation/rails/releases/tag/v1.2) (2015-07-03)

#### New features:

 * Ensure the correct locale can be set only for the current thread.

## [v1.1.3](https://github.com/translation/rails/releases/tag/v1.1.3) (2015-03-31)

#### New features:

 * Ensure GetText.locale is in sync with I18n's default locale at boot

## [v1.1.2](https://github.com/translation/rails/releases/tag/v1.1.2) (2015-03-18)

#### New features:

 * Better specs

#### Fixes (bugs & defects):

 * Fix HAML and SLIM parsing and import.

## [v1.1.0](https://github.com/translation/rails/releases/tag/v1.1.0) (2015-03-17)

#### New features:

 * Allow users to edit source text of YAML keys in Translation.io interface.
 * `rake translation:sync` will now get the new sources into the app before synchronizing translations.

## [v1.0.1](https://github.com/translation/rails/releases/tag/v1.0.1) (2015-01-08)

#### Fixes (bugs & defects):

 * Development dependencies resolution in gemspec.

## [v1.0.0](https://github.com/translation/rails/releases/tag/v1.0.0) (2015-01-08)

#### New features:

 * Better set_locale
 * POT/PO headers improvement when syncing.

#### Fixes (bugs & defects):

 * Adding a new language in your Rails project before syncing no longer breaks the PO header.

## [v0.9.7](https://github.com/translation/rails/releases/tag/v0.9.7) (2014-12-12)

#### New features:

 * Better localization files management :
   * Don't copy empty keys from source locale anymore
   * Keep keys that are only in targets
   * Manage transliterations
 * `LOCALIZATION_KEY_PREFIXES` option in gem
 * `rake translation:sync_and_purge` instead of `rake translation:purge`

#### Fixes (bugs & defects):

 * Debug charset issues

## [v0.9.5](https://github.com/translation/rails/releases/tag/v0.9.5) (2014-10-10)

#### New features:

 * Deep merge of YAML files before flatten
 * Custom ignored key prefixes

## [v0.9.4](https://github.com/translation/rails/releases/tag/v0.9.4) (2014-09-26)

#### New features:

 * Use HTTPS to sync with translation.io
 * Can deal with .ruby and .rabl files containing GetText localization

## [v0.9.3](https://github.com/translation/rails/releases/tag/v0.9.3) (2014-09-11)

#### Fixes (bugs & defects):

 * Fix issue when there is absolutely no YAML keys on the init (happens when not-english source language)

## [v0.9.2](https://github.com/translation/rails/releases/tag/v0.9.2) (2014-09-09)

#### Fixes (bugs & defects):

 * Does not break on empty YAML files loading

## [v0.9.1](https://github.com/translation/rails/releases/tag/v0.9.1) (2014-09-05)

#### New features:

 * Better management of reserved keys in YAML (no, n, true, false, etc.)

## [v0.9](https://github.com/translation/rails/releases/tag/v0.9) (2014-09-05)

#### New features:

 * Better management of localization keys in YAML (delimiters, boolean values, integers, etc.)

