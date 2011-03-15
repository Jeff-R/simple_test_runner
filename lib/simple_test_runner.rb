#!/home/jeff/.rvm/rubies/ruby-1.9.2-p0/bin/ruby
require "rubygems"
require "bundler/setup"
require_relative 'runner_opts'
require 'rb-inotify'

# Bundler.require        # See http://technotales.wordpress.com/2010/08/22/bundler-without-rails/

# code originally swiped shamelessly from https://github.com/ewollesen/autotest-inotify/blob/master/lib/autotest/inotify.rb
# Mostly morphed since then ...

module SimpleTestRunner

  class TestRunner

    def initialize args = []
      @args = args
    end

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
      unless @options.configfileok
        puts "Couldn't find the configuration file."
        puts "  The config file is where you place the command that"
        puts "  you want the program to run."
        puts
        puts "  It should be a text file called .simpletestrunnerrc."
        puts "  To generate the file, run 'simpletestrunner -c'"
        puts "  then edit it by hand."
        return
      end
      unless @options.parsed.ok
        @options.print_usage
        return
      end

      if @options.parsed.show_config
        @options.show_config
      end

      if not @options.parsed.fake
        setup_monitor
        @notifier.run
      end
    end

    def running_linux?
      /linux/i === RbConfig::CONFIG["host_os"]
    end

    def setup_monitor
      @notifier = INotify::Notifier.new
      @options.parsed.dirs_to_monitor.each do |dir|
        foo = @notifier.watch(dir, :modify, :recursive) { run_command }
      end
    end

    def event_of_interest?(flags)
      flags.include?(:modify) || flags.include?(:moved_to)
    end

    def run_command
        system "#{@options.parsed.command_str}"
    end

  end
end
