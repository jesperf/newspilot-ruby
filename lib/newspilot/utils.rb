module Newspilot
  # borrowed from https://github.com/balanced/balanced-ruby/blob/master/lib/balanced/utils.rb
  # thanks!
  module Utils
    def demodulize(class_name_in_module)
      class_name_in_module.to_s.sub(/^.*::/, '')
    end

    def pluralize(word)
      word.to_s.sub(/([^s])$/, '\1s')
    end

    def underscore(camel_cased_word)
      word = camel_cased_word.to_s.dup
      word.gsub!(/::/, '/')
      word.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      word.tr! '-', '_'
      word.downcase!
      word
    end

    def camelize_lower(word)
      word.camelize(:lower)
    end

    extend self
  end
end
