module Base
  class Program
    DecodeError = Class.new(StandardError)

    attr_reader :memory
    attr_accessor :start_location

    def initialize
      @start_location = 0
      @memory = []
    end

    def encode
      bytecode = ['B'.ord, 'A'.ord, 'S'.ord, 'E'.ord, 2, start_location] + memory

      bytecode.flat_map do |value|
        bytes = []
        while value >= 128
          bytes << ((value & 127) | 128).chr
          value >>= 7
        end
        bytes + [value.chr]
      end.join
    end

    def decode(data)
      raise DecodeError, "invalid header signature" unless data[0..4] == "BASE\2"

      bytecode = []
      carry = 0
      value = 0
      data[5..-1].each_byte do |byte|
        if byte & 128 == 128
          value |= (byte & 127) << carry
          carry += 7
        else
          bytecode << ((byte << carry) | value)
          carry = value = 0
        end
      end

      raise DecodeError, "unexpected end of bytecode" unless carry == 0

      @start_location = bytecode[0]
      @memory = bytecode[1..-1]
      true
    end
  end
end
