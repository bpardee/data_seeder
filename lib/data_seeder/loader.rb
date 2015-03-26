require 'English'

module DataSeeder
  module Loader
    attr_accessor :file_config, :key_attribute
    attr_reader   :path, :path_minus_ext

    def initialize(options={})
      @only = options[:only]
      @except = options[:except]
      if options.has_key?(:purge)
        @purge = options[:purge]
      else
        @purge = true
      end
      @old_keys = []
    end

    def config
      DataSeeder.config
    end

    def logger
      DataSeeder.logger
    end

    def klass
      # This should always translate to a class except for custom loaders
      @path_minus_ext.classify.constantize rescue nil
    end

    def process(path)
      @path           = path
      dot_index       = @path.rindex('.')
      @path_minus_ext = @path[0, dot_index]
      @file_config    = {}
      cfg_file = "#{@path_minus_ext}.cfg"
      @file_config = eval(File.read(cfg_file)) if File.exist?(cfg_file)
      File.open(@path, 'r') do |fin|
        load_file_config(fin) if @file_config.empty?
        @file_config = ActiveSupport::HashWithIndifferentAccess.new(@file_config)
        setup
        load(fin)
        teardown
      end
      call_file_method(:teardown)
    end

    def setup
      @key_attribute = self.file_config[:key_attribute] || :id
      @old_keys = self.klass.all.pluck(@key_attribute).map(&:to_s) if @purge
      logger.info { "Loading #{@path}" }
      call_file_method(:setup)
    end

    def teardown
      @old_keys.each do |key|
        if model = self.klass.find_by(@key_attribute => key)
          logger.info { "  Destroying #{model_info(model)}"}
          model.destroy
        end
      end
    end

    # The information displayed when creating, updating, or destroying a model.
    # The changes argument will be the model.changes on an update.
    def model_info(model, changes=nil)
      if changes
        attr = @file_config[:update_display_method] || @key_attribute
        "#{model.send(attr)}: #{changes.inspect}"
      else
        model.inspect
      end
    end

    def load_file_config(fin)
      config_line = fin.readline
      if match = config_line.match(/^\s*#\s*config:(.*)/)
        @file_config = eval(match[1])
      else
        fin.seek(0)
        if self.klass && self.klass.respond_to?(:data_seeder_config)
          @file_config = self.klass.data_seeder_config
        end
      end
    end

    def load(fin)
      throw 'Must override load'
    end

    def line_number
      $INPUT_LINE_NUMBER
    end

    def save(attr)
      if @file_config[:use_line_number_as_id]
        key = self.line_number
      else
        key = attr[@key_attribute.to_s] || attr[@key_attribute.to_sym]
        raise "No #{@key_attribute} in #{attr.inspect}" unless key
      end
      @old_keys.delete(key.to_s)
      model = self.klass.find_or_initialize_by(@key_attribute => key)
      model.attributes = attr
      save_model(model)
    end

    def save_model(model)
      if model.new_record?
        logger.info { "  Saving #{model_info(model)}" }
      else
        changes = model.changes
        return if changes.empty?
        logger.info { "  Updating #{model_info(model, changes)}" }
      end
      model.save!
    end

    def call_file_method(name, *args)
      if method = @file_config[name]
        return method.call(*args)
      else
        class_method = "data_seeder_#{name}"
        return self.klass.send(class_method, *args) if @klass.respond_to?(class_method)
      end
      return nil
    end
  end
end

require 'data_seeder/loader/csv'
require 'data_seeder/loader/json'
require 'data_seeder/loader/yaml'
require 'data_seeder/loader/txt'
