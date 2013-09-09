module Context
  class Context
    attr_reader :name, :path

    def initialize(path)
      @name = File.basename(path)
      @path = path
    end

    def to_s
      @name
    end
  end
end
