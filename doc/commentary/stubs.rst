It's sometimes useful to be able to create an empty stub which will be pointed to a real definition later.

The simple solution is just to do:

  : foo ;

This creates a new defintion ("foo"), with no runtime action. In Retro all colon definitions can be revectored, so this is all that is strictly required. It does have a downside with regard to readability. We can address this by defining a new word specifically to create stubs.

  : stub ( "- ) create 0 , 0 , 9 , ['] .word last @ d->class ! ;

Examining this one in a bit more detail:

  create       :::  Create a new name in the dictionary
  0 ,          :::  Inline an opcode for "NOP"
  0 ,          :::  Inline an opcode for "NOP"
  9 ,          :::  Inline an opcode for "RETURN"
  ['] .word    :::  Get address of ".word" class
  last @       :::  Get dictionary header of most recently created word
  d->class !   :::  Set class field of header to the ".word" class

The two NOP opcodes are critical: the vector words replace the two with a jump instruction to the actual definition later on.

Given this, we can also define a simple loop to create a series of stubs:

  : stubs ( n"- ) for stub next ;

And then:

  stub cursor
  4 stubs up down left right
