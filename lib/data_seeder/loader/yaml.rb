require 'yaml'

module DataSeeder
  module Loader
    class YAML
      include Loader

      def load(io)
        yaml = ::YAML.load(io.read)
        if yaml.kind_of?(Hash)
          yaml.each do |key, attr|
            attr[self.key_attribute] = key if self.key_attribute
            save(attr)
          end
        elsif yaml.kind_of?(Array)
          yaml.each { |attr| save(attr) }
        else
          raise "Don't know how to interpret #{self.path}"
        end
      end
    end
  end
end
