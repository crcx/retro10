=================
Extracting Blocks
=================

First, in Retro:

::

  offset @ . bye

Then, in bash:

::

  dd if=retroImage of=blocks ibs=4 skip=#

Replace **#** with the number displayed by Retro.

================
Injecting Blocks
================

First, in Retro:

::

  offset @ . bye

Then, at the shell:

::

  dd if=blocks of=retroImage ibs=4 bs=4 seek=#

Again, **#** is the number displayed by Retro.
