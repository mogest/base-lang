module Base
  class Debugger
    attr_reader :vm

    PUSH = VM::COMMANDS.index("push")

    def initialize(vm)
      @vm = vm
    end

    def debug
      loop do
        next_instruction = memory[ip] == PUSH ? "push #{memory[ip + 1]}" : VM::COMMANDS[memory[ip]] || "???"
        puts "ip=#{ip} stack=#{stack.inner} #{next_instruction}"
        print "> "

        command = $stdin.gets&.strip
        case command
        when ""
          nil
        when "n"
          return true
        when "c", nil
          return false
        when "q"
          exit
        when /\Am(?:\s+([0-9]+))?(?:\s+([0-9]+))?/
          memory_dump($1 && $1.to_i || 0, $2 && $2.to_i)
        when /\Ad(?:\s+([0-9]+))?(?:\s+([0-9]+))?/
          disassemble($1 && $1.to_i || ip, $2 && $2.to_i)
        else
          puts "n - next instruction"
          puts "c - stop debugging and continue"
          puts "m [start [length]] - dump memory"
          puts "d [start [length]] - disassemble"
          puts "q - quit"
        end
      end
    end

    private

    def memory
      vm.memory
    end

    def ip
      vm.ip
    end

    def stack
      vm.stack
    end

    def memory_dump(location, length)
      data = memory[location..(length ? location + length - 1 : -1)]

      data.each_slice(8).with_index.each do |slice, index|
        print "%8d | " % (location + index * 8)
        slice.each do |byte|
          print "%4d " % byte
        end
        puts
      end
    end

    def disassemble(location, length)
      end_location = length ? location + length : memory.length

      while location < end_location && memory[location]
        initial_location = location
        op_code = memory[location]

        if op_code == PUSH
          value = memory[location + 1]
          instruction = "push #{value}"
          location += 2
        else
          instruction = VM::COMMANDS[op_code] || "#{op_code}???"
          location += 1
        end

        puts "%8d | %s" % [initial_location, instruction]
      end
    end
  end
end
