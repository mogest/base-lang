module Base
  class Compiler
    Error = Class.new(StandardError)

    def initialize
      @parsing = []
      @memory = []
      @labels = {}
      @macros = {}
    end

    def compile(file)
      lines = File.read(file).split("\n")
      parse(lines)

      main = @labels["main"] || 0
      [main] + @memory
    end

    private

    def parse(lines)
      lines.each.with_index do |line, index|
        begin
          parse_line(line, index + 1)
        rescue Error => e
          raise Error, "#{e.message} on line #{index + 1}"
        end
      end

      @parsing.each do |index, line_number|
        begin
          @memory[index] = parse_arg(@memory[index], index)
        rescue Error => e
          raise Error, "#{e.message} on line #{line_number}"
        end
      end
    end

    def parse_line(line, number, macro_entry = [])
      line = line.gsub(/#(.+)/, '').strip
      case line
      when ""
        nil

      when /\A\.([a-z_][a-z0-9_]*)(?:\s+(.+))?\z/i
        raise Error, "label already defined" if @labels[$1]
        raise Error, "can't use 'ip' as a label name" if $1 == 'ip'
        @labels[$1] = @memory.length
        @memory += parse_static($2) if $2

      when /\Apush\s+(.+)\z/
        @memory += [VM::COMMANDS.index("push"), $1]
        @parsing << [@memory.length - 1, number]

      when /\Amacro\s+(\S+)\s+(.+)/
        raise Error, "label already defined" if @macros[$1]
        raise Error, "macros cannot replace base instructions" if VM::COMMANDS.member?($1)
        @macros[$1] = $2.split(/\s*,\s*/)

      else
        if op_code = VM::COMMANDS.index(line)
          @memory << op_code
        elsif macro = @macros[line]
          if macro_entry.include?(macro)
            raise Error, "recursive call to macro #{macro}"
          end

          macro.each do |macro_line|
            parse_line(macro_line, number, macro_entry + [macro])
          end
        else
          raise Error, "unknown command '#{line}'"
        end
      end
    end

    def parse_arg(arg, location)
      case arg
      when '"\n"'
        "\n".ord
      when /\A"\\?([^"])"\z/
        $1.ord
      when "ip"
        location - 1
      when /\A(-?[0-9]+)\z/
        $1.to_i
      when /\A([a-z_][a-z0-9_]*)\z/i
        @labels[$1] or raise Error, "no such label '#{$1}'"
      else
        raise Error, "unknown argument '#{arg}'"
      end
    end

    def parse_static(arg)
      chars = arg.chars
      output = []
      buffer = ""
      state = :start

      loop do
        char = chars.shift
        if char == "-" && state == :start
          buffer = "-"
          state == :number
        elsif ("0".."9").include?(char) && [:start, :number].include?(state)
          buffer += char
          state = :number
        else
          if state == :number
            output << buffer.to_i
            buffer = ""
            state = :start
          end

          if char.nil?
            if state == :start
              break output
            else
              raise Error, "invalid data"
            end
          end

          if [',', ' '].include?(char) && state == :start
            nil
          elsif char == '"' && state == :start
            state = :string
          elsif char == '"' && state == :string
            output += buffer.chars.map(&:ord)
            buffer = ""
            state = :start
          elsif char == '\\' && state == :string
            state = :escape
          elsif state == :string
            buffer << char
          elsif state == :escape
            if char == "n"
              buffer << "\n"
            else
              buffer << char
            end
            state = :string
          else
            raise Error, "invalid data"
          end
        end
      end
    end
  end
end
