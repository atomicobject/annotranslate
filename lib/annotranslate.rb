require 'active_support'
require 'action_view/helpers/translation_helper'

# Extentions to make internationalization (i18n) of a Rails application simpler.
# Support the method +translate+ (or shorter +t+) in models/view/controllers/mailers.
module AnnoTranslate
  # Error for use within Translator
  class AnnoTranslateError < StandardError #:nodoc:
  end

  # Translator version
  VERSION = '1.0.0'

  # Whether to pseudo-translate all fetched strings
  @@pseudo_translate = false

  # Pseudo-translation text to prend to fetched strings.
  # Used as a visible marker. Default is "["
  @@pseudo_prepend = "["

  # Pseudo-translation text to append to fetched strings.
  # Used as a visible marker. Default is "]"
  @@pseudo_append = "]"

  # An optional callback to be notified when there are missing translations in views
  @@missing_translation_callback = nil

  # Invokes the missing translation callback, if it is defined
  def self.missing_translation_callback(exception, key, options = {}) #:nodoc:
    @@missing_translation_callback.call(exception, key, options) if !@@missing_translation_callback.nil?
  end

  # Set an optional block that gets called when there's a missing translation within a view.
  # This can be used to log missing translations in production.
  #
  # Block takes two required parameters:
  # - exception (original I18n::MissingTranslationData that was raised for the failed translation)
  # - key (key that was missing)
  # - options (hash of options sent to annotranslate)
  # Example:
  #   set_missing_translation_callback do |ex, key, options|
  #     logger.info("Failed to find #{key}")
  #   end
  def self.set_missing_translation_callback(&block)
    @@missing_translation_callback = block
  end

  def self.translate_with_annotation(key, options={})
    puts "AnnoTranslate: translate_with_annotation(key=#{key}, options=#{options.inspect}"

    str = I18n.translate(key, options)

    # If pseudo-translating, prepend / append marker text
    if AnnoTranslate.pseudo_translate? && !str.nil?
      str = AnnoTranslate.pseudo_prepend + str + AnnoTranslate.pseudo_append
    end

    str
  end

  class << Translator

    # Generic translate method that mimics <tt>I18n.translate</tt> (e.g. no automatic scoping) but includes locale fallback
    # and strict mode behavior.
    def translate(key, options={})
      AnnoTranslate.translate_with_annotation(key, options)
    end

    alias :t :translate
  end

  # When fallback mode is enabled if a key cannot be found in the set locale,
  # it uses the default locale. So, for example, if an app is mostly localized
  # to Spanish (:es), but a new page is added then Spanish users will continue
  # to see mostly Spanish content but the English version (assuming the <tt>default_locale</tt> is :en)
  # for the new page that has not yet been translated to Spanish.
  def self.fallback(enable = true)
    @@fallback_mode = enable
  end

  # If fallback mode is enabled
  def self.fallback?
    @@fallback_mode
  end

  # Toggle whether to true an exception on *all* +MissingTranslationData+ exceptions
  # Useful during testing to ensure all keys are found.
  # Passing +true+ enables strict mode, +false+ installs the default exception handler which
  # does not raise on +MissingTranslationData+
  def self.strict_mode(enable_strict = true)
    @@strict_mode = enable_strict

    if enable_strict
      # Switch to using contributed exception handler
      I18n.exception_handler = :strict_i18n_exception_handler
    else
      I18n.exception_handler = :default_exception_handler
    end
  end

  # Get if it is in strict mode
  def self.strict_mode?
    @@strict_mode
  end

  # Toggle a pseudo-translation mode that will prepend / append special text
  # to all fetched strings. This is useful during testing to view pages and visually
  # confirm that strings have been fully extracted into locale bundles.
  def self.pseudo_translate(enable = true)
    @@pseudo_translate = enable
  end

  # If pseudo-translated is enabled
  def self.pseudo_translate?
    @@pseudo_translate
  end

  # Pseudo-translation text to prepend to fetched strings.
  # Used as a visible marker. Default is "[["
  def self.pseudo_prepend
    @@pseudo_prepend
  end

  # Set the pseudo-translation text to prepend to fetched strings.
  # Used as a visible marker.
  def self.pseudo_prepend=(v)
    @@pseudo_prepend = v
  end

  # Pseudo-translation text to append to fetched strings.
  # Used as a visible marker. Default is "]]"
  def self.pseudo_append
    @@pseudo_append
  end

  # Set the pseudo-translation text to append to fetched strings.
  # Used as a visible marker.
  def self.pseudo_append=(v)
    @@pseudo_append = v
  end

  # Additions to TestUnit to make testing i18n easier
  module Assertions

    # Assert that within the block there are no missing translation keys.
    # This can be used in a more tailored way that the global +strict_mode+
    #
    # Example:
    #   assert_translated do
    #     str = "Test will fail for #{I18n.t('a_missing_key')}"
    #   end
    #
    def assert_translated(msg = nil, &block)

      # Enable strict mode to force raising of MissingTranslationData
      AnnoTranslate.strict_mode(true)

      msg ||= "Expected no missing translation keys"

      begin
        yield
        # Credtit for running the assertion
        assert(true, msg)
      rescue I18n::MissingTranslationData => e
        # Fail!
        assert_block(build_message(msg, "Exception raised:\n?", e)) {false}
      ensure
        # uninstall strict exception handler
        AnnoTranslate.strict_mode(false)
      end

    end
  end

  module I18nExtensions
    # Add an strict exception handler for testing that will raise all exceptions
    def strict_i18n_exception_handler(exception, locale, key, options)
      # Raise *all* exceptions
      raise exception
    end

  end
end

module ActionView #:nodoc:
  class Base
    # Redefine the +translate+ method in ActionView (contributed by TranslationHelper) that is
    # context-aware of what view (or partial) is being rendered.
    # Initial scoping will be scoped to [:controller_name :view_name]
    def translate_with_annotation(key, options={})

      # In the case of a missing translation, fall back to letting TranslationHelper
      # put in span tag for a translation_missing.
      begin
        AnnoTranslate.translate_with_annotation(key, options.merge({:raise => true}))
      rescue AnnoTranslate::AnnoTranslateError, I18n::MissingTranslationData => exc
        # Call the original translate method
        str = translate_without_annotation(key, options)

        # View helper adds the translation missing span like:
        # In strict mode, do not allow TranslationHelper to add "translation missing" span like:
        # <span class="translation_missing">en, missing_string</span>
        if str =~ /span class\=\"translation_missing\"/
          # In strict mode, do not allow TranslationHelper to add "translation missing"
          raise if AnnoTranslate.strict_mode?

          # Invoke callback if it is defined
          AnnoTranslate.missing_translation_callback(exc, key, options)
        end

        str
      end
    end

    alias_method_chain :translate, :annotation
    alias :t :translate
  end
end

module ActionController #:nodoc:
  class Base

    # Add a +translate+ (or +t+) method to ActionController
    def translate_with_annotation(key, options={})
      AnnoTranslate.translate_with_annotation(key, options)
    end

    alias_method_chain :translate, :annotation
    alias :t :translate
  end
end

module ActiveRecord #:nodoc:
  class Base
    # Add a +translate+ (or +t+) method to ActiveRecord
    def translate(key, options={})
      AnnoTranslate.translate_with_annotation(key, options)
    end

    alias :t :translate

    # Add translate as a class method as well so that it can be used in validate statements, etc.
    class << Base

      def translate(key, options={}) #:nodoc:
        AnnoTranslate.translate_with_annotation(key, options)
      end

      alias :t :translate
    end
  end
end

module ActionMailer #:nodoc:
  class Base

    # Add a +translate+ (or +t+) method to ActionMailer
    def translate(key, options={})
      AnnoTranslate.translate_with_annotation(key, options)
    end

    alias :t :translate
  end
end

module I18n
  # Install the strict exception handler for testing
  extend AnnoTranslate::I18nExtensions
end

module Test # :nodoc: all
  module Unit
    class TestCase
      include AnnoTranslate::Assertions
    end
  end
end

# In test environment, enable strict exception handling for missing translations
if (defined? RAILS_ENV) && (RAILS_ENV == "test")
  AnnoTranslate.strict_mode(true)
end