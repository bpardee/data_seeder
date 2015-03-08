require 'yaml'

module DataSeeder
  module Loader
    class YAML
      include Loader

      def load_io(io)
        if key_attribute = self.file_config[:key_attribute]
          self.file_config[:update_display_method] = key_attribute
        end
        ::YAML.load(io.read).each do |key, attr|
          attr[key_attribute] = key if key_attribute
          save(attr)
        end
      end
    end
  end
end
