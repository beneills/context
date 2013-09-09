Dir["#{File.join(File.dirname(__FILE__), "context")}/*.rb"].each do |lib|
  require lib
end

module Context
  class Contexts
    def initialize(root_directory)
      @root_directory = root_directory
      @directory = Directory.new(@root_directory)
    end

    def context(name)
      contexts.find { |c| c.name == name }
    end

    def contexts
      @directory.contexts
    end

    def create(name)
      @directory.create(name)
    end

    def current
      @directory.current
    end

    def enter(context)
      @directory.enter(context)
    end

    def exit(context)
      @directory.exit(context)
    end

    def switch(name)
      c = context(name)
      raise "Context: <#{name}> does not exist!" if c.nil?
      raise "Already in context: <#{name}>!" if c == current

      exit(current)
      enter(c)
      @directory.update_current(c)
    end
  end
end
