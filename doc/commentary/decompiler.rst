Quite a while ago, I wrote a decompiler (**see**) for Retro. It's proven
to be a very useful tool, but with repeated hacks, etc, it became less
clean than I like. I recently decided to take some time to revise it and
work out some of the uglier bits.

The **addr** variable holds the current address being decompiled.

::

  variable addr

One major shortcoming of the old decompiler was the output format. It was
accurate, but poorly formatted. In revising it, I wanted to ensure that the
code would be displayed in nice, neat columns. This is one word that helps
a good bit there. It's used to provide spacing between values (from literals,
jumps, and calls) and the corresponding symbolic names.

::

  : pad       ( -   ) addr @ @ 6 for dup base @ r pow <if 32 emit then next ;

To help make the output more understandable, I wrote the following to resolve
names. This loops through the dictionary comparing the value of the current
address to the xt of a dictionary header. If a match is found, **.name** is
called to display the name (enclosed in parenthesis).

::

  : .wrap     ( -   ) ." ( " later ."  )" ;
  : .name     ( a-  ) .wrap d->name type ;
  : resolve   ( -   ) last @ repeat dup d->xt @ addr @ @ =if .name ;then 0; @ again ;

The main piece of code is a giant conditional loop. Rather than code each
conditional by hand, I'm using a few macros and words to build it for me. To
do this, I need words to handle two types of instructions:

- simple opcodes that take one cell. These are created with **sym:**

- compound opcodes that take a cell, and a value from the following cell. These are created with **sym+:**

The conditional format needed is pretty simple:

::

  ( opcode value ) over =if s" opcode name" type drop ;then

The first part is easy by using the **`** word:

::

  ` over ` =if

I defined **.symbol** to lay down the code to display a symbol and the drop:

  : .symbol   ( "-  ) token ` .op ` drop ; immediate

This definition uses two more words: **token** and **.op**:

  : token     ( "-  ) 32 accept tib keepString literal, ;
  : .op       ( a-  ) dup getLength swap type 5 swap - 0; for 32 emit next ;

The macro uses **token** to read in a string (delimited by a space), and
compile the string into the definition with **keepString literal,**. The
**.op** displays the string, padded to 5 spaces to ensure proper alignment
of columns.

So with these, we get the **sym:** macro:

::

  : sym:      ( "-  ) ` over ` =if ` .symbol ` ;then ; immediate

For the compound opcodes, we need one extra step: display of the corresponding
value (jump target, literal, etc). For this, we define one more word: **.value**

::

  : .value    (  -  ) addr ++ addr @ @ . pad resolve ;

And then a **sym+:** macro:

::

  : sym+:     ( "-  ) ` over ` =if ` .symbol ` .value ` ;then ; immediate

Now the support code is complete and we can move on to the actual decompiler
word. It's literally a giant set of if/then blocks, built with the **sym:**
and **sym+:** macros. If a value is unknown, it'll display the raw value.

::

  : decompile ( - )
    addr @ @
     0 sym: nop      1 sym+: lit      2 sym: dup       3 sym: drop
     4 sym: swap     5 sym: push      6 sym: pop       7 sym+: call
     8 sym+: jump    9 sym: ;        10 sym+: >jump   11 sym+: <jump
    12 sym+: !jump  13 sym+: =jump   14 sym: @        15 sym: !
    16 sym: +       17 sym: -        18 sym: *        19 sym: /mod
    20 sym: and     21 sym: or       22 sym: xor      23 sym: <<
    24 sym: >>      25 sym: 0;       26 sym: 1+       27 sym: 1-
    28 sym: in      29 sym: out      30 sym: wait
    ." Unknown: " .  cr
  ;

Now for the most hairy piece of code: determining the end of a definition. In Retro,
there's no failsafe way to do this, but we can make a good guess if we have a return
(**;**, opcode 9) followed by non-valid instructions (probably a dictionary header),
or two non-ops (**nop**, opcode 0) for the start of the next word. This won't always
be true, but should be good enough for most purposes.

::

  : header? addr @ @ 9 =if addr @ 1+ @ 30 >if addr @ . decompile pop pop 2drop then then ;
  : vector? addr @ @ 0 =if addr @ 1+ @ 0 =if pop pop 2drop then then ;
  : more? header? vector? ;

In the above, note the **pop pop 2drop** to exit the top-level calling word.

And finally, we tie it all together with a simple word that gets an xt, stores it in
**addr**, and does a simple loop to display an address, decompile, and advance to the
next address:

::

  : see  ( "-  ) ' addr ! cr repeat addr @ . decompile cr addr ++ more? again ;
