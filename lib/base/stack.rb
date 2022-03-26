module Base
  class Stack
    Error = Class.new(StandardError)

    def initialize
      @stack = []
    end

    def push(value)
      @stack.push(value)
    end

    def pop
      @stack.pop or raise Error, "pop requested on empty stack"
    end

    def empty?
      @stack.empty?
    end

    def inner
      @stack
    end
  end
end
