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
      puts "load_yaml: yaml = #{yaml.inspect}"
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

    def load_config_file 
      yaml = File.new(config_file_name).read
      load_yaml yaml
    end

    def config_file_name 
      ".simpletestrunnerrc"
    end

    def configfileok
      File.exists? config_file_name
    end

    def print_usage
      puts @optionParser
    end

    def show_config
      puts "Configuration:"
      puts "config file:     \"#{config_file_name}\""
      puts "dirs to monitor: #{@parsed.dirs_to_monitor.inspect}"
      puts "command to run:  \"#{@parsed.command_str}\""
      puts "fake run:        #{@parsed.fake}"
    end

    def parse args
      @parsed.verbose          ||= false
      @parsed.make_config_file ||= false
      @parsed.show_config      ||= false
      @parsed.dirs_to_monitor  ||= ['foo', 'bar', 'baz']
      @parsed.ok               ||= false
      @parsed.command_str      ||= "echo 'Dir changed'"
      @parsed.fake             ||= false

      @optionParser = OptionParser.new do |opts|
        opts.banner = "Usage: simpletestrunner [options]"

        # Command to run
        opts.on("-c", "--command COMMAND", String, "Command to run") do |commandstr|
          @parsed.command_str = commandstr
        end

        # Create a config file
        opts.on("-C", "--configfile", "create a config file") do 
          @parsed.make_config_file = true
          @parsed.ok = true
        end

        # List of dirs.
        opts.on("-d", "--dirs x,y,z", Array, "example 'list' of arguments") do |list|
          @parsed.dirs_to_monitor = list
        end

        # show help
        opts.on('-h', "--help", "Print out this message") do |url|
          puts opts
          @parsed.ok = true
        end

        # fake run
        opts.on("-f", "--fake", "Fake run: don't actually monitor the dirs") do 
          @parsed.fake = true
        end

        # Show configuration
        opts.on('-s', '--show', 'Show the current configuration') do |password|
          @parsed.show_config = true
          @parsed.ok = true
        end

      end

      @optionParser.parse!(args)
      @parsed
    end

  end
end
