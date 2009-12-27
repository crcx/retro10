===========
Basic Usage
===========

Starting
--------
Get a copy of the VM (**retro**) and the image file (**retroImage**) in
the current directory, then:

::

   ./retro

Interacting with Retro
----------------------
Unlike most Forths, Retro does not buffer on a line by line basis. Input
is parsed as it is typed, and words are executed when the spacebar is
hit.

This is a significant source of confusion to users coming from other
Forth systems. Just remember: only space is recognized by a default
Retro system as a valid separator between words.

By default, cr, lf, and tab are remapped to be identical to space.
This can be disabled by typing:

::

  whitespace off

To turn it back on:

::

  whitespace on

Leaving Retro
-------------
Just type **bye** and hit space.

Images
------
The Retro language is stored in an image file. When you start Retro,
the VM looks for a **retroImage** file. If if can't find one, it uses
a minimal image that is built in instead.

You can **save** your current Retro session to a retroImage by using
the **save** word, and reload it later. All words/variables you have
created will be kept and you can continue working without having to
reload or retype everything.

You can also use the vector functionality in Retro to replace/alter
most of the existing words to meet your needs.
