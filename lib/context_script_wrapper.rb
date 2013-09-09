#!/usr/bin/env ruby

require 'fileutils'
require 'trollop'

opts = Trollop::options do
  opt :root, "Root context location.", :default => File.join(Dir.home, '.context')
end

raise "Please supply script filename!" if ARGV.empty?

pid = Process.spawn({},
                    ENV['SHELL'], *ARGV,
                    :out => '/dev/null', :err => '/dev/null')

pids_directory = File.join(opts.root, 'pids')
Dir.mkdir(pids_directory) if !File.directory?(pids_directory)
pid_filename = File.join(pids_directory, pid.to_s)

FileUtils.touch(pid_filename)

Process.wait(pid)

File.delete(pid_filename) if File.exists?(pid_filename)
