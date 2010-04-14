module TinyMCE
  class Configuration
    # We use this to combine options and raw_options into one class and validate
    # whether options passed in by the users are valid tiny mce configuration settings.
    # Also loads which options are valid, and provides an plugins attribute to allow
    # more configuration options dynamicly

    DEFAULT_OPTIONS = {
      'mode' => 'textareas',
      'editor_selector' => 'mceEditor',
      'theme' => 'simple',
      'language' => (defined?(I18n) ? I18n.locale : :en)
    }

    def self.config_file_options
      @@config_file_options ||= begin
        tiny_mce_yaml_filepath = File.join(RAILS_ROOT, 'config', 'tiny_mce.yml')
        # The YAML file might not exist, might be blank, might be invalid, or
        # might be valid. Catch all cases and make sure we always return a Hash
        (YAML::load(IO.read(tiny_mce_yaml_filepath)) rescue nil) || Hash.new
      end
    end

    # Parse the options file and load it into an array
    # (this method is called when tiny_mce is initialized - see init.rb)
    def self.valid_options
      @@valid_options ||= begin
        valid_options_path = File.join(File.dirname(__FILE__), 'valid_tinymce_options.yml')
        File.open(valid_options_path) { |f| YAML.load(f.read) }
      end
    end

    attr_accessor :options, :raw_options

    def initialize(options = {}, raw_options = nil)
      options = Hash.new unless options.is_a?(Hash)
      @options = DEFAULT_OPTIONS.merge(self.class.config_file_options.stringify_keys).
                                 merge(options.stringify_keys)
      @raw_options = [raw_options]
    end

    # Merge additional options and raw_options
    def add_options(options = {}, raw_options = nil)
      @options.merge!(options.stringify_keys) unless options.blank?
      @raw_options << raw_options unless raw_options.blank?
    end

    # Merge additional options and raw_options, but don't overwrite existing
    def reverse_add_options(options = {}, raw_options = nil)
      @options.reverse_merge!(options.stringify_keys) unless options.blank?
      @raw_options << raw_options unless raw_options.blank?
    end

    def plugins
      @options['plugins'] || []
    end

    # Validate and merge options and raw_options into a string
    # to be used for tinyMCE.init() in the raw_tiny_mce_init helper
    def to_json
      raise TinyMCEInvalidOptionType.invalid_type_of(plugins, :for => :plugins) unless plugins.is_a?(Array)

      json_options = []
      @options.each_pair do |key, value|
        raise TinyMCEInvalidOption.invalid_option(key) unless valid?(key)
        json_options << "#{key} : " + case value
        when String, Symbol, Fixnum
          "'#{value.to_s}'"
        when Array
          '"' + value.join(',') + '"'
        when TrueClass
          'true'
        when FalseClass
          'false'
        else
          raise TinyMCEInvalidOptionType.invalid_type_of(value, :for => key)
        end
      end

      json_options.sort!

      @raw_options.compact!
      json_options += @raw_options unless @raw_options.blank?

      "{\n" + json_options.delete_if {|o| o.blank? }.join(",\n") + "\n\n}"
    end

    # Does the check to see if the option is valid. It checks the valid_options
    # array (see above), checks if the start of the option name is in the plugin list
    # or checks if it's an theme_advanced_container setting
    def valid?(option)
      option = option.to_s
      self.class.valid_options.include?(option) ||
        plugins.include?(option.split('_').first) ||
        option =~ /^theme_advanced_container_\w+$/
    end
  end
end
