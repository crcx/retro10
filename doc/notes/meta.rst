===================
Metacompiling Retro
===================

Overview
--------
Retro is built using a metacompiler. The metacompiler ("meta")
consists of two parts: an assembler, and a target compiler.

The assembler provides the core functionality for labels and
the Ngaro instruction set. It stores code to a special memory
area, with jumps and label references being relocated as if
the base address was zero. It is not possible to invoke code
written with meta before the final relocation.

The target compiler extends the assembler to provide a machine
forth with colon definitions, conditionals, and loops. It also
has support for building an initial dictionary and a few core
word classes. Meta also contains code to relocate the compiled
code and save it, replacing the retroImage with the newly
compiled code.


Using the Metacompiler
----------------------
When the metacompiler is loaded, it initializes a target memory
area of 4096 cells in size. Two variables (**target** and
**origin**) are created and set to point to the start of this
region.

Data is written to the target memory area using **m,**. This word
takes a value off the stack, writes it to the address **target**
points to, then advances **target** by 1.

The symbolic opcodes use m, to write their values to the target
memory region. Refer to Table 1 for a list of opcodes provided
by the assembler.

Some opcodes require an additional value in the memory location
that follows them. These opcodes are:

+--------+
| lit,   |
+--------+
| call,  |
+--------+
| jump,  |
+--------+
| >jump, |
+--------+
| <jump, |
+--------+
| =jump, |
+--------+
| !jump, |
+--------+

The first, **lit,**, takes a value from the following location
and pushes it to the stack. The others take an address to call
or branch to.

The assembler portion also provides support for labels via the
**label:** word. Labels can be referenced as variables or address
values to call or branch to.

Since execution of an image always starts with address 0, the
assembler compiles a **jump,** instruction there upon creating
the target region. You can mark the actual entry point using
**main:**.

An example of the assembler:

::

  label: foo 10 m,     ( variable 'foo', with initial value of 10 )

  label: bar     ( we'll reference 'bar' as a word name )
         lit, foo m,   ( compile a literal pointer to 'foo' )
         @,            ( fetch instruction to get the contents of 'foo' )
         ;,            ( and exit instruction to end our word )

  main:                ( mark the main entry point )
         call, bar m,  ( compile a call to 'bar' )
         halt,         ( and end the program )

The assembler also has two helper words to make things a bit
more readable. These are **#** and **$,**. The word **#** replaces
the **lit, value m,** sequence with **value #**, while **$,** copies
a string into the target memory area. Using **#**, we can rewrite
the example above to be slightly more readable:

::

  label: bar
         foo # @, ;,

Note that multiple instructions can be placed on each line. Our
sample now appears a bit more like traditional Forth code.

The metacompiler also provides a colon compiler and a few Forth
words that can be used to make things much cleaner:

::

  10 variable: foo
  t: bar foo # @, ;
  main: bar halt,

These words are covered in Table 2.

The final major piece of the metacompiler is support for creating
the initial classes and dictionary. Three variables (**'WORD** **'MACRO**
and **'DATA**) are created for the initial classes. You can use
**set-class** to set these to point to words in the target image.
This *must* be done before you can create the initial dictionary.

The dictionary can be built using the following words:

+------------------+
| word:            |
+------------------+
| macro:           |
+------------------+
| data:            |
+------------------+
| patch-dictionary |
+------------------+
| mark-dictionary  |
+------------------+

Use **mark-dictionary** before creating the variable for the
dictionary chain. After the dictionary is created, use the
**patch-dictionary** word to update the variable with the actual
dictionary pointer.


=======
Opcodes
=======

+--------+---------------------------------------+
| Opcode | Description                           |
+--------+---------------------------------------+
| nop,   | Do nothing                            |
+--------+---------------------------------------+
| lit,   | Push a value to the stack             |
+--------+---------------------------------------+
| dup,   | Duplicate TOS                         |
+--------+---------------------------------------+
| drop,  | Lose TOS                              |
+--------+---------------------------------------+
| swap,  | Swap TOS and NOS                      |
+--------+---------------------------------------+
| push,  | Move a value from data stack to the   |
|        | address stack                         |
+--------+---------------------------------------+
| pop,   | Move a value from address stack to    |
|        | data stack                            |
+--------+---------------------------------------+
| call,  | Call a subroutine                     |
+--------+---------------------------------------+
| jump,  | Jump to a new address                 |
+--------+---------------------------------------+
| ;,     | Return from a call                    |
+--------+---------------------------------------+
| >jump, | Jump if NOS is greather than TOS      |
+--------+---------------------------------------+
| <jump, | Jump if NOS is less than TOS          |
+--------+---------------------------------------+
| !jump, | Jump if TOS and NOS are not equal     |
+--------+---------------------------------------+
| =jump, | Jump if TOS and NOS are equal         |
+--------+---------------------------------------+
| @,     | Fetch from address at TOS             |
+--------+---------------------------------------+
| !,     | Store NOS to address in TOS           |
+--------+---------------------------------------+
| +,     | Add TOS to NOS                        |
+--------+---------------------------------------+
| -,     | Subtract TOS from NOS                 |
+--------+---------------------------------------+
| \*,    | Multiply TOS and NOS                  |
+--------+---------------------------------------+
| /mod,  | Divide and get Remainder              |
+--------+---------------------------------------+
| and,   | Bitwise AND                           |
+--------+---------------------------------------+
| or,    | Bitwise OR                            |
+--------+---------------------------------------+
| xor,   | Bitwise XOR                           |
+--------+---------------------------------------+
| >>,    | Shift bits right                      |
+--------+---------------------------------------+
| <<,    | Shift bits left                       |
+--------+---------------------------------------+
| 0;     | Return and drop TOS if TOS is 0.      |
|        | If TOS is not 0, do nothing.          |
+--------+---------------------------------------+
| 1+,    | Increment TOS by 1                    |
+--------+---------------------------------------+
| 1-,    | Decrement TOS by 1                    |
+--------+---------------------------------------+
| in,    | Read a value from an I/O port         |
+--------+---------------------------------------+
| out,   | Send a value to an I/O port           |
+--------+---------------------------------------+
| wait,  | Wait for an I/O event                 |
+--------+---------------------------------------+
| halt,  | Illegal opcode; terminate the VM      |
+--------+---------------------------------------+


===============
Target Compiler
===============

+-----------+------------------------------------+
| Word      | Description                        |
+-----------+------------------------------------+
| t:        | Start a colon defintion in the     |
|           | target                             |
+-----------+------------------------------------+
| t'        | Get a pointer in the target        |
+-----------+------------------------------------+
| ;         | End a colon definition             |
+-----------+------------------------------------+
| <if       | Compare for less than, branch to   |
|           | 'then' if not                      |
+-----------+------------------------------------+
| >if       | Compare for greater than, branch to|
|           | 'then' if not                      |
+-----------+------------------------------------+
| !if       | Compare for inequality. If not,    |
|           | branch to 'then'                   |
+-----------+------------------------------------+
| =if       | Compare for equality. Branch to    |
|           | 'then' if not                      |
+-----------+------------------------------------+
| then      | End a conditional                  |
+-----------+------------------------------------+
| repeat    | Start of an unconditional loop     |
+-----------+------------------------------------+
| again     | Close an unconditional loop        |
+-----------+------------------------------------+
| variable: | Create a variable with an initial  |
|           | value                              |
+-----------+------------------------------------+
| variable  | Create a variable with a value of 0|
+-----------+------------------------------------+
