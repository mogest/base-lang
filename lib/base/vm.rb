module Base
  class VM
    Error = Class.new(StandardError)

    MAX_MEMORY = 1048576

    attr_reader :ip, :stack, :memory

    COMMANDS = %w(debug push discard duplicate write read add subtract multiply divide jump bltz bgtz betz bnetz out halt)

    def initialize(program, debug: false)
      @ip = program.shift
      @memory = program
      @debug = debug
      @stack = Stack.new
    end

    def run
      loop do
        raise Error, "IP reached end of memory" if memory[ip].nil?

        @debug = Debugger.new(self).debug if @debug

        begin
          result = execute
          break if result == :halt
        rescue Error => e
          $stderr.puts("error: #{e.message}")
          @debug = true
        end
      end

      raise Error, "warning: stack not empty at program termination, #{stack.inner}" unless @stack.empty?
    end

    private

    def execute
      case COMMANDS[memory[ip]]
      when "debug"
        @debug = true

      when "halt"
        return :halt

      when "push"
        @ip += 1
        arg = memory[ip]
        stack.push(arg)

      when "discard"
        stack.pop
      when "duplicate"
        value = stack.pop
        stack.push(value)
        stack.push(value)

      when "write"
        location = stack.pop
        value = stack.pop
        write(location, value)
      when "read"
        location = stack.pop
        stack.push(read(location))

      when "add"
        a = stack.pop
        b = stack.pop
        stack.push(a + b)
      when "subtract"
        a = stack.pop
        b = stack.pop
        stack.push(b - a)
      when "multiply"
        a = stack.pop
        b = stack.pop
        stack.push(b * a)
      when "divide"
        a = stack.pop
        b = stack.pop
        raise Error, "divide by 0" if a == 0
        stack.push(b / a)

      when "jump"
        @ip = stack.pop - 1
      when "bltz"
        dest = stack.pop
        test = stack.pop
        @ip = dest - 1 if test < 0
      when "bgtz"
        dest = stack.pop
        test = stack.pop
        @ip = dest - 1 if test > 0
      when "betz"
        dest = stack.pop
        test = stack.pop
        @ip = dest - 1 if test == 0
      when "bnetz"
        dest = stack.pop
        test = stack.pop
        @ip = dest - 1 if test != 0

      when "out"
        print(stack.pop.chr)
      else
        raise Error, "invalid op code #{memory[ip]}"
      end

      @ip += 1
    rescue Error, Stack::Error => e
      raise Error, "#{e.message} at IP #{ip}"
    end

    private

    def read(location)
      validate_location(location)
      memory[location] || 0
    end

    def write(location, value)
      validate_location(location)
      memory[location] = value
    end

    def validate_location(location)
      raise Error, "locations must be non-negative" if location < 0
      raise Error, "locations must be less than #{MAX_MEMORY}" if location >= MAX_MEMORY
    end
  end
end
