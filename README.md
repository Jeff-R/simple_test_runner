## simple_test_runner is a very simple replacement for autotest.

In short: 

* It monitors a set of directories.
* If a file changes in one of those directories, simple_test_runner runs an arbitrary command.
* Normally, that command would run a unit test or spec. But it could be anything.
* simple_test_runner only runs on Linux. Any help generalizing it to other platforms would be very nice.

## Using simple_test_runner

Running simple_test_runner without any options will print out this message:

    Usage: simple_test_runner [options]
    -c, --command COMMAND            Command to run
    -d, --dirs x,y,z                 example 'list' of arguments
    -f, --fake                       Fake run: don't actually monitor the dirs
    -h, --help                       Print out this message
    -s, --show                       Show the current configuration


So, to run all specs when files in the app/ or lib/ directories are updated:

    simple_test_runner -d app,lib -c "rspec spec"

To stop simple_test_runner, use control-c. You might have to then modify one of the files being monitored so it wakes up and notices the control-c. And, yes, this is a pretty ugly way to stop it. I'm going to try to fix that.

## But why?

"But why?" I hear you ask.

Autotest is great. But ... it can be overkill. And it polls your files for changes. Every second. Yes, with extra helpers it can run without polling. But then there's the configuration.

And the configuration is ... touchy. Unseen things lurk in the background. Doing things for you. "Helping" you. 

After hours of tracking down scattered documentation for obscure bugs, after walking through autotest's source code to identify just where the hell it was doing things and what it was doing, I snapped.

And I wrote this.

The idea is to keep it simple. You tell testRuner which directories to watch for changes, and what command to run when changes happen. And that's all.

Any time a file in the watched directory changes, the command is run.

To quit, type control-c in the terminal running the program, and wait for the next directory change to wake it up. Kinda klunky, I know. If anyone knows a better way to handle it, I'm all ears.

## Installation

### As a gem

      gem install simple_test_runner


### From github

* Get 

      git clone git://github.com/Jeff-R/simple_test_runner.git

* Build 

      cd simple_test_runner
      rake build

* Install (with rvm)

      rvm use gemset global
      rake install

* Install (without rvm)

      sudo gem install pkg/simple_test_runner_x.gem



## System requirements

At the moment, simple_test_runner only runs on Linux, because it uses the Linux kernel's INotify feature. I'd love to have it be extended for different platforms, but I'll need help for that.


