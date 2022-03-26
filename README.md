# Base

A simple stack-based assembly programming language and VM, made for learning.

## Using it

Enter a simple program:

    # alphabet.base

    .main
      push "A"

    .loop
      # Print letter to the screen
      duplicate
      out

      # Check whether we've reached Z yet
      duplicate
      push "Z"
      subtract

      # If we have, we're done
      push done
      betz

      # Advance to the next letter and loop
      push 1
      add
      push loop
      jump

    .done
      # Program ends
      discard
      push "\n"
      out
      halt

Run it:

    % gem install base-lang

    % base alphabet.base
    ABCDEFGHIJKLMNOPQRSTUVWXYZ

## Language

All instructions take no arguments except the `push` instruction which takes the value to push to the stack.

Values may be an integer, a single character in double quotes which is interpreted as its unicode number, a label representing a memory location, or the special text `ip` which refers to the current instruction pointer.

Signed integers of arbitrary size can be used.  Memory locations start at 0 and by default go up to 1MB.

operation | op code | stack impact | description
-|-|-|-
debug | 0 | | enters the debugger
push (value or label) | 1, value | + | pushes the value onto the stack
discard | 2 | - | discards the top entry on the stack
duplicate | 3 | -++ | pushes two copies of the top entry on the stack
write | 4 | -- | writes the second entry on the stack to the memory location at the top entry on the stack
read | 5 | -+ | reads from the memory location on the stack and puts the result on the stack
add | 6 | --+ | adds the top two entries on the stack and puts the result on the stack
subtract | 7 | --+ | subtracts the top entry on the stack from the second entry on the stack and puts the result on the stack
multiply | 8 | --+ | multiplies the top two entries on the stack and puts the result on the stack
divide | 9 | --+ | divides the top entry on the stack from the second entry on the stack and puts the integer result on the stack
jump | 10 | - | jumps to the location indicated by the top entry on the stack
bltz | 11 | -- | jumps to the location indicated by the top entry on the stack if the second entry on the stack is less than 0
bgtz | 12 | -- | jumps to the location indicated by the top entry on the stack if the second entry on the stack is greater than 0
betz | 13 | -- | jumps to the location indicated by the top entry on the stack if the second entry on the stack is equal to 0
bnetz | 14 | -- | jumps to the location indicated by the top entry on the stack if the second entry on the stack is not equal to 0
out | 15 | - | outputs the top entry on the stack to stdout, interpreted as a unicode character
halt | 16 | | halts the program

## Compiler

Any text including and after a `#` in the code is treated as a comment and ignored.

### Labels and data

You can use labels to mark a place in the code:

    # infinite loop
    .marker
      push marker
      jump

`.main` is a special label. If specified, code execution will start at this point.

You can also use labels to introduce data:

    .three_bytes 1, 2, 3

The data can also be a string, which is interpreted as a list of bytes, or a mix of the two

    .message "Hello!", 10, 0

### Macros

Simple macros can be defined as a comma-separated list of operations (or other macros, as long as they don't recurse):

    macro increment push 1, add
 
    push "A"
    increment
    out # outputs a "B"

You'll need to define a macro before you use it in your file.

## Debugger

Base has an integrated debugger that allows you to trace through your code, view memory and stack, and disassemble code.

You can start it by calling `debug` in your program, or by running `base` with the `--debug` option in which case
it'll start immediately on program startup.

When in the debugger, type `h` for help.

## Licence and contributing

MIT licence.

Feel free to contribute!  It's intentionally simple, and as a result it's unlikely we'll add more instructions or syntactic
sugar than what's already there.
