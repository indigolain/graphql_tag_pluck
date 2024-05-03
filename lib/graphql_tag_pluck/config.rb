module GraphqlTagPluck

  class Config
    CONFIG_FILE = File.expand_path(".graphqltagpluckconfig.yaml", Dir.pwd)

    attr_reader :options

    def self.load
      new.load
    end

    def initialize
      @options = {}
    end

    def load
      load_file(CONFIG_FILE)
      @options
    end

    private

    def load_file(path)
      if File.exist?(path)
        YAML.load_file(path).each do |key, value|
          key = key.to_sym
          @options[key] = value
        end
      end
    end
  end
end
