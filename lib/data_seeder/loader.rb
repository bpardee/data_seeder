require 'English'

module DataSeeder
  module Loader
    attr_accessor :key_attribute
    attr_reader   :klass, :path, :path_minus_ext, :config

    def logger
      DataSeeder.logger
    end

    def default_config
      { purge: true }
    end

    # Returns nil if the path was not ready for processing due to dependencies
    def process(path)
      @path           = path
      dot_index       = @path.rindex('.')
      @path_minus_ext = @path[0, dot_index]
      cfg_file = "#{@path_minus_ext}.cfg"
      begin
        @klass = @path_minus_ext.classify.constantize
      rescue NameError => e
        @klass = nil
      end
      @config = default_config
      if @klass && @klass.respond_to?(:data_seeder_config)
        @config = @config.merge(@klass.data_seeder_config)
      end
      if File.exist?(cfg_file)
        @config = @config.merge(eval(File.read(cfg_file)))
      end
      File.open(@path, 'r') do |io|
        # TODO: Lets get rid of this load_file_config stuff.  It's too hacky and may cause problems for
        # non-file IO types.
        load_file_config(io)
        depends = call_method(:depends)
        return nil if depends && !SeedFile.processed?(depends)
        process_io(io)
      end
      call_method(:teardown)
      return true
    end

    def process_io(io, config={})
      @config = (@config || default_config).merge(config)
      @key_attribute = @config[:key_attribute] || :id
      setup
      load(io)
      teardown
    end

    def setup
      if @config[:purge]
        @old_ids = klass.all.pluck(:id).to_set
      else
        @old_ids = Set.new
      end
      logger.info { "Loading #{@path}" }
      call_method(:setup)
    end

    def teardown
      @old_ids.each do |id|
        if model = klass.find_by(id: id)
          destroy_model(model)
        end
      end
    end

    # The information displayed when creating, updating, or destroying a model.
    # The changes argument will be the model.changes on an update.
    def model_info(model, changes=nil)
      if changes
        attr = @config[:update_display_method] || @key_attribute
        "#{model.send(attr)}: #{changes.inspect}"
      else
        model.inspect
      end
    end

    def load_file_config(io)
      config_line = io.readline
      if match = config_line.match(/^\s*#\s*config:(.*)/)
        @config = @config.merge(eval(match[1]))
      else
        io.seek(0)
      end
    end

    def load(io)
      throw 'Must override load'
    end

    def line_number
      $INPUT_LINE_NUMBER
    end

    def save(attr)
      attr = call_method(:preprocess, attr) || attr
      if @config[:use_line_number_as_id]
        key = self.line_number
      else
        key = attr[@key_attribute.to_s] || attr[@key_attribute.to_sym]
        raise "No #{@key_attribute} in #{attr.inspect}" unless key
      end
      call_method(:postprocess)
      model = self.klass.find_or_initialize_by(@key_attribute => key)
      model.attributes = attr
      save_model(model)
    end

    def save_model(model)
      if model.new_record?
        log_save(model)
      else
        @old_ids.delete(model.id)
        return unless model.changed?
        log_update(model)
      end
      model.save!
    end

    # Allow override for potential soft-delete
    def destroy_model(model)
      log_destroy(model)
      model.destroy
    end

    def log_save(model)
      #logger.info { "  Saving #{model_info(model)}" }
    end

    def log_update(model)
      logger.info { "  Updating #{model_info(model, model.changes)}" }
    end

    def log_destroy(model)
      logger.info { "  Destroying #{model_info(model)}"}
    end

    def call_method(name, *args)
      if ![:setup,:teardown].include?(name) && self.respond_to?(name)
        return send(name, @args)
      elsif val = @config[name]
        if val.kind_of?(Proc)
          return val.call(*args)
        else
          return val
        end
      else
        if @klass
          class_method = "data_seeder_#{name}"
          return @klass.send(class_method, *args) if @klass.respond_to?(class_method)
        end
      end
      return nil
    end
  end
end

require 'data_seeder/loader/csv'
require 'data_seeder/loader/json'
require 'data_seeder/loader/yaml'
require 'data_seeder/loader/txt'
