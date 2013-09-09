require 'fileutils'

module Context
  class Directory
    attr_reader :contexts

    def initialize(root_directory)
      @root_directory = root_directory

      Dir.mkdir(root_directory) if !File.exists?(root_directory)
      Dir.mkdir(contexts_path) if !File.exists?(contexts_path)
      Dir.mkdir(pids_path) if !File.exists?(pids_path)

      @contexts = Dir.entries(contexts_path).select {|f| !File.directory? f}.map do |c|
        Context.new(File.join(contexts_path, c))
      end

      d = default
      if d.nil?
        d = Context.new(File.join(contexts_path, 'default'))
        # make context skeleton
        Dir.mkdir(d.path)
        Dir.mkdir(action_path(d, 'enter'))
        Dir.mkdir(action_path(d, 'exit'))
        enter_sh = File.join(d.path, "enter.sh")
        exit_sh = File.join(d.path, "exit.sh")
        FileUtils.touch(enter_sh)
        FileUtils.chmod("ugo+x", enter_sh)
        FileUtils.touch(exit_sh)
        FileUtils.chmod("ugo+x", exit_sh)
        @contexts << d
      end

      if !File.symlink?(current_path) or current.nil?
        update_current(d)
      end
    end

    def create(name)
      raise "Context: <#{name}> already exists!" if @contexts.find { |c| c.name == name }
      c = Context.new(File.join(contexts_path, name))
      FileUtils.cp_r(default.path, c.path)
      @contexts << c
    end

    def action_path(context, action)
      File.join(contexts_path, context.name, action)
    end

    def pids_path
      File.join(@root_directory, 'pids')
    end

    def contexts_path
      File.join(@root_directory, 'contexts')
    end

    def default
      @contexts.find { |c| c.name == 'default' }
    end

    def current
      name = File.basename(File.readlink(current_path))
      @contexts.find { |c| c.name == name }
    end

    def current_path
      File.join(@root_directory, 'current')
    end

    def enter(context)
      action_paths(context, 'enter').each do |s|
        run(s)
      end
    end

    def exit(context)
      # make sure all enter processes are done
      Dir["#{pids_path}/*"].each do |pid_file|
        pid = File.basename(pid_file).to_i

        #system "kill #{pid}"
        Process.kill("INT", pid.to_i)
      end
      # then run exit scripts
      action_paths(context, 'exit').each do |s|
        run(s, auto_kill=false)
      end
    end
    
    def run(script, auto_kill=true)
      puts "Run: #{script}"

      wrapper = File.join(File.dirname(File.dirname(__FILE__)), 'context_script_wrapper.rb')
      runner = auto_kill ? wrapper : ENV['SHELL']

      pid = Process.spawn({},
                          runner, script,
                          :out => '/dev/null', :err => '/dev/null')
      # we can now forget about this
      Process.detach pid
    end

    def action_paths(context, action)
      ap = action_path(context, action)
      scripts = Array.new
      sh = File.join(context.path, "#{action}.sh")
      scripts << sh if File.executable?(sh)
      if File.directory?(ap)
        Dir.entries(ap).select {|f| !File.executable? f}.each do |s|
          scripts << s
        end
      end
      scripts
    end

    def update_current(context)
      File.delete(current_path) if File.exists?(current_path)
      File.symlink(context.path, current_path)
    end
  end
end
