#!/home/jeff/.rvm/rubies/ruby-1.9.2-p0/bin/ruby
require "rubygems"
require "bundler/setup"
require_relative 'runner_opts'

Bundler.require        # See http://technotales.wordpress.com/2010/08/22/bundler-without-rails/

# code swiped shamelessly from https://github.com/ewollesen/autotest-inotify/blob/master/lib/autotest/inotify.rb

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
        print_usage
        return
      end
    end

    def running_linux?
      /linux/i === RbConfig::CONFIG["host_os"]
    end

    # @dirs_to_monitor = %w( test1 test2  )
    @dirs_to_monitor = [ "test1", "test2" ]

    def setup_monitor
      dirs_to_monitor = [ "test1", "test2" ]
      @notifier = INotify::Notifier.new
      # Watch directories to catch delete/move swap patterns as well as direct
      # modifications.  This handles, e.g. :w in vim.
      dirs_to_monitor.each do |dir|
        @notifier.watch(dir, :all_events) do |event|
          if event_of_interest?(event.flags) &&
            files.include?(event.absolute_name)
            handle_file_event(event)
          end
        end
      end
    end

    def event_of_interest?(flags)
      flags.include?(:modify) || flags.include?(:moved_to)
    end

    def handle_file_event(event)
      puts ("Saw a change!")
      # @changed_files[event.absolute_name] = Time.now
    end

    def select_all_tests
      map_files_to_tests_for(find_files).each do |filename|
        self.files_to_test[filename]
      end
    end

    def map_files_to_tests_for(files)
      files.map {|filename, mtime| test_files_for(filename)}.flatten.uniq
    end

    def select_tests_for_changed_files
      map_files_to_tests_for(@changed_files).each do |filename|
        self.files_to_test[filename]
      end
    end


    def setup_inotify
      @notifier = INotify::Notifier.new
      files = self.find_files.keys
      dirs = files.map{|f| File.dirname( f )}.uniq
      # Watch directories to catch delete/move swap patterns as well as direct
      # modifications.  This handles, e.g. :w in vim.
      dirs.each do |dir|
        @notifier.watch(dir, :all_events) do |event|
          if event_of_interest?(event.flags) &&
            files.include?(event.absolute_name)
            handle_file_event(event)
          end
        end
      end
    end

  end


end

# tr = TestRunner.new
# tr.setup_monitor

