#!/home/jeff/.rvm/rubies/ruby-1.9.2-p0/bin/ruby
require "rubygems"
require "bundler/setup"
require 'rb-inotify'
require 'io/wait'   # for io.ready?

require 'runner_opts'

# Bundler.require        # See http://technotales.wordpress.com/2010/08/22/bundler-without-rails/

# code originally swiped shamelessly from https://github.com/ewollesen/autotest-inotify/blob/master/lib/autotest/inotify.rb
# Mostly morphed since then ...

module SimpleTestRunner

  # Top-level class
  class TestRunner

    # Initialized gets passed ARGv
    def initialize args = []
      @args = args
    end

    # This is the function that runs everything.
    def run
      if not running_linux?
        puts "Sorry. This program currently only runs in Linux."
        puts "If you want other platforms to be supported, please help out!"
        return
      end

      @options = RunnerOpts.new @args
      if @options.parsed.make_config_file
        make_config_file
        return
      end
      # unless @options.configfileok
      #   puts "Couldn't find the configuration file."
      #   puts "  The config file is where you place the command that"
      #   puts "  you want the program to run."
      #   puts
      #   puts "  It should be a text file called .simpletestrunnerrc."
      #   puts "  To generate the file, run 'simpletestrunner -c'"
      #   puts "  then edit it by hand."
      #   return
      # end
      unless @options.parsed.ok
        @options.print_usage
        return
      end

      if @options.parsed.show_config
        @options.show_config
      end

      if not @options.parsed.fake
        if @options.parsed.dirs_to_monitor.length > 0
          setup_monitor 
          while not STDIN.ready?
            @notifier.process
          end
        end
      end
    end

    # Make a config file.
    # Currently not used. I was planning on using a config file
    # for directories to monitor and the command to run.
    # But at the moment everything goes on the command line,
    # and I think that's simpler.
    # But I'm leaving the config file functions in the code,
    # in case I decide to pick them up again.
    def make_config_file
      if File.exists? @options.config_file_name
        puts "Are you sure? (y for yes)"
        a = gets.strip.downcase
        return unless a == "y"
      end
      File.open(@options.config_file_name, 'w+') do |file| 
        file.puts @options.to_yaml
      end
    end

    # Are we running on Linux? 
    # returns true or false
    # The program currently only supports Linux.
    def running_linux?
      /linux/i === RbConfig::CONFIG["host_os"]
    end

    # Set up the INotify::Notifier object to watch for changes
    # to the target dirs.
    def setup_monitor
      @notifier = INotify::Notifier.new
      @options.parsed.dirs_to_monitor.each do |dir|
        foo = @notifier.watch(dir, :modify, :recursive) { run_command }
      end
    end

    # Run the command that was specified on the command line.
    def run_command
        system "#{@options.parsed.command_str}"
    end

  end
end
