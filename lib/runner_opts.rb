require 'optparse'
require 'ostruct'
require 'yaml'

module SimpleTestRunner
  class RunnerOpts
    def initialize(args, path="")
      @parsed = OpenStruct.new
      parse(args)
      # if not path == ""
      #   @parsed.dirs_to_monitor = ""
      # end
    end

    def load_yaml yaml_string
      yaml = YAML::load(yaml_string)

      @parsed.command  = yaml["command"]
    end

    def to_yaml
      "command: echo 'hello'"
    end

    def config_file_name= filename
      @parsed.config_file_name = filename
    end

    def parsed= val
      @parsed = val
    end

    def parsed
      @parsed
    end

    def save_to_file
      File.open(@parsed.config_file_name, 'w+') do |file|
        file.puts to_yaml
      end
    end

    def load_file filename
      yaml = File.new(filename).read
      load_yaml yaml
    end

    def config_file_name 
      ".simpletestrunnerrc"
    end

    def configfileok
      File.exists? config_file_name
    end

    def parse args
      @parsed.verbose          ||= false
      @parsed.make_config_file ||= false
      @parsed.show_config      ||= false
      @parsed.dirs_to_monitor  ||= ['foo', 'bar', 'baz']

      @optionParser = OptionParser.new do |opts|
        opts.banner = "Usage: simpletestrunner [options]"

        opts.on('-h', "--help", "Print out this message") do |url|
          puts opts
        end

        opts.on("-c", "--configfile", "create a config file") do 
          @parsed.make_config_file = true
        end

        opts.on('-s', '--show', 'Show the current configuration') do |password|
          puts "PresserOpts: show config is true"
          @parsed.show_config = true
        end

      end

      @optionParser.parse!(args)
      @parsed
    end


  end
end
