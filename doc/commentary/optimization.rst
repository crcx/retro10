In a standard Retro system, the following is an example of how code is compiled:

  : foo 10 20 + 1+ . ;

foo:
  lit 10
  lit 20
  call +
  call 1+
  call .
  return

Since some words (like + and 1+) correspond directly to Ngaro instructions, we could potentially inline them, giving:

foo:
  lit 10
  lit 20
  +
  1+
  call .
  return

This cuts memory use down by two cells (instructions are one cell, calls take two) and reduces the number of calls/returns, giving faster performance.

So now for the code:

  : .primitive ( a- )
    dup @ 0 =if compiler @ -1 =if 2 + @ , ;; then then .word ;

This is our new class. Breaking it down:

  dup @          ::: Get first instruction in defintion
  0 =if          ::: If 0, it's not revectored
    compiler @   ::: Get the compiler state
    -1 =if       ::: If TRUE, we can inline
      2 + @      ::: So skip the prefix for vectors and get the instruction
      ,          ::: And inline it into the target definition
      ;;         ::: Exit the class handler
    then         :::
  then           :::
  .word          ::: If the word was revectored, or if we are interpreting, use .word class

Given this, we can reassign the instruction words to use the .primitive class and get the benefits of inlining.

  : .primitive ( a- )
    dup @ 0 =if compiler @ -1 =if 2 + @ , ;; then then .word ;

  ( Helper to make it easier to change class )
  : p: ( "- ) ' drop ['] .primitive which @ d->class ! ;

  p: 1+     p: 1-
  p: swap   p: drop
  p: and    p: or
  p: xor    p: @
  p: !      p: +
  p: -      p: *
  p: /mod   p: <<
  p: >>     p: nip
  p: dup    p: in
  p: out

  ( Remove helper since it's no longer needed )
  forget p:

