Overview
--------
Retro has a word (**eval**) that allows for using a string as an
input source. This is a somewhat tricky word, and doesn't work
the way you'd expect.

How It Works
------------

- Stores a pointer to the string and the length

- When the interpreter is in control, passes values from the string
  to the interpreter as if they were being typed at the keyboard

Important Note
--------------
Because evaluation is done only at the interpreter level, you can't
just do something like:

::

   : foo ( -n ) s" base" dup getLength eval @ ;

What will happen is this:

- **foo** gets called

- the string is processed (**dup getLength**) and passed to **eval**

- **eval** stores a pointer to the string and the length

- **eval** remaps the keyboard handler (**ekey**) to read input from the string

- control is passed back to **foo**

- **@** is called. If there's a value on the stack, it'll fetch from this,
  otherwise it'll likely crash.

- After **foo** exits, the interpreter evaluates the string

You could do:

::

   : foo ( -n ) s" base @" dup getLength eval ;

Which would process the **@** at the interpreter, but having it in the definition
will *not* work.
