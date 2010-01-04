Code Style in Retro
===================
:Author: Charles Childers
:Version: 2009.12.22


Choosing Names
--------------
This is probably the most important. I'll just say:

- short names are preferable

- readable, make longer if too cryptic


Variables and Constants
-----------------------
Variables left visible should either be descriptive or use a format like the one below to indicate the app they belong to (this is preferred):

::

   appname:variable


Words
-----
Again, short but descriptive. If you have internal factors exposed to the dictionary, try to use a format like:

::

    appname.name

Using the above guidelines for variables, constants, and words makes it easy to identify what application the words are associated with.


Stack Comments
--------------
Two things here:

- All words should have stack comments

- Use the short form, not the more traditional long form

- Try to keep them lined up when possible; it helps with visual form.


Indention
---------
Indent by 2 spaces. Do **not** use tabs.

Bad:

::

   : foo ( n- )
   1+ . ;

Better:

::

   : foo ( n- )
     1+ . ;

Of course, in the above, it's best to do one line:

::

   : foo ( n- ) 1+ . ;

But for longer words, each level of indention should be 2 spaces.


Trailing Whitespace
-------------------
I personally regard this as a bad thing, and remove any trailing whitespace from code sent to me. If you use the Nano editor, you can have it highlight trailing whitespace by adding this to your ~/.nanorc:

::

   syntax "default"
   color ,green "[[:space:]]+$"

Change the color (*green*) to whatever works best for you.


Line Length
-----------
I try not to exceed 64 characters. Longer lines are ok, but if you want to allow loading your code into blocks at some point, you'll need to take care with longer lines.
